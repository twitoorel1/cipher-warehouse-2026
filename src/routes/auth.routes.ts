import { NextFunction, Router, Response } from "express";
import type { Pool } from "mysql2/promise";
import { login, refresh, logout } from "../services/auth/auth.service.js";
import type { AppEnv } from "../config/env.js";
import { z } from "zod";
import momentTimezone from "moment-timezone";
import { AppError } from "@/middleware/error.middleware.js";
import { validate } from "@/middleware/validate.middleware.js";

const loginBodySchema = z.object({
  username_or_email: z.string().trim().min(3).max(120),
  password: z.string().min(8).max(200),
});

function isProd() {
  return process.env.NODE_ENV === "production";
}

function refreshCookieOptions(env: AppEnv) {
  const maxAgeMs = env.jwt.refreshTtlDays * 24 * 60 * 60 * 1000;
  return {
    httpOnly: true,
    secure: env.nodeEnv === "production",
    sameSite: "strict" as const, // אם חייבים cross-site אז "lax" + Origin check חובה
    path: "/auth",
    maxAge: maxAgeMs,
  };
}

export function requireKnownOrigin(env: AppEnv) {
  return (req: any, _res: Response, next: NextFunction) => {
    const origin = req.get("origin");
    const referer = req.get("referer");

    const candidate = origin ?? (referer ? safeRefererOrigin(referer) : null);
    if (candidate) {
      const ok = env.corsOrigins.some((o) => candidate.startsWith(o));
      if (!ok) {
        return next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden (origin)" }));
      }
      return next();
    }
    if (env.nodeEnv !== "production") return next();
    return next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden (missing origin)" }));
  };
}

function safeRefererOrigin(referer: string): string | null {
  try {
    const u = new URL(referer);
    return `${u.protocol}//${u.host}`;
  } catch {
    return null;
  }
}

export function createAuthRouter(db: Pool, env: AppEnv) {
  const router = Router();

  router.post("/login", validate(loginBodySchema), async (req, res, next) => {
    try {
      const { username_or_email, password } = req.body as z.infer<typeof loginBodySchema>;
      const result = await login(db, env, { username_or_email, password }, { userAgent: req.get("user-agent") ?? null, ip: req.ip ?? null });

      res.cookie("rt", result.refreshToken, refreshCookieOptions(env));

      const expiresAt = momentTimezone().toDate().getTime() + env.jwt.accessTtlSeconds * 1000;
      res.status(200).json({
        userid: result.userId,
        role: result.role,
        access_token: result.accessToken,
        expires_at: new Date(expiresAt).toLocaleString(),
        expires_in: env.jwt.accessTtlSeconds,
      });
    } catch (e) {
      next(e);
    }
  });

  router.post("/refresh", requireKnownOrigin(env), async (req, res, next) => {
    try {
      const rt = req.cookies?.rt ?? null;
      const result = await refresh(db, env, rt, { userAgent: req.get("user-agent") ?? null, ip: req.ip ?? null });

      res.cookie("rt", result.newRefreshToken, refreshCookieOptions(env));

      const expiresAt = momentTimezone().toDate().getTime() + env.jwt.accessTtlSeconds * 1000;
      res.status(200).json({
        userid: result.userId,
        role: result.role,
        access_token: result.accessToken,
        expires_at: new Date(expiresAt).toLocaleString(),
        expires_in: env.jwt.accessTtlSeconds,
      });
    } catch (e) {
      res.clearCookie("rt", refreshCookieOptions(env));
      next(e);
    }
  });

  router.post("/logout", requireKnownOrigin(env), async (req, res, next) => {
    try {
      const rt = req.cookies?.rt ?? null;
      await logout(db, rt);

      res.clearCookie("rt", refreshCookieOptions(env));
      res.sendStatus(204);
    } catch (e) {
      next(e);
    }
  });

  return router;
}
