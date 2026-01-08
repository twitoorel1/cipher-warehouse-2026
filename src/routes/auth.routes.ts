import { Router } from "express";
import type { Pool } from "mysql2/promise";
import { login, refresh, logout } from "../services/auth/auth.service.js";
import type { AppEnv } from "../config/env.js";
import momentTimezone from "moment-timezone";
import { AppError } from "@/middleware/error.middleware.js";

function isProd() {
  return process.env.NODE_ENV === "production";
}

function refreshCookieOptions(env: AppEnv) {
  const maxAgeMs = env.jwt.refreshTtlDays * 24 * 60 * 60 * 1000;
  return {
    httpOnly: true,
    secure: isProd(),
    sameSite: "strict" as const, // אם חייבים cross-site אז "lax" + Origin check חובה
    path: "/auth",
    maxAge: maxAgeMs,
  };
}

// CSRF מינימלי: מאשר רק origins מוכרים כשהבקשה נשענת על cookie
function requireKnownOrigin(env: AppEnv) {
  return (req: any, _res: any, next: any) => {
    const origin = req.get("origin") || req.get("referer") || "";
    // אם אין origin (יש קליינטים שלא שולחים) – בפרודקשן עדיף לחסום ל-refresh/logout
    if (!origin) return next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));

    const ok = env.corsOrigins.some((o) => origin.startsWith(o));
    if (!ok) return next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
    next();
  };
}

export function createAuthRouter(db: Pool, env: AppEnv) {
  const router = Router();

  router.post("/login", async (req, res, next) => {
    try {
      const { username_or_email, password } = req.body;
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

  router.post("/refresh", async (req, res, next) => {
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

  router.post("/logout", async (req, res, next) => {
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
