import { Router } from "express";
import type { Pool } from "mysql2/promise";
import { login, refresh, logout } from "../services/auth/auth.service.js";
import type { AppEnv } from "../config/env.js";
import momentTimezone from "moment-timezone";

export function createAuthRouter(db: Pool, env: AppEnv) {
  const router = Router();

  router.post("/auth/login", async (req, res, next) => {
    try {
      const { username_or_email, password } = req.body;
      const result = await login(db, env, { username_or_email, password }, { userAgent: req.get("user-agent") ?? null, ip: req.ip ?? null });

      res.cookie("rt", result.refreshToken, {
        httpOnly: true,
        secure: false,
        sameSite: "lax",
        path: "/auth",
      });

      const expiresAt = momentTimezone().toDate().getTime() + env.jwt.accessTtlSeconds * 1000;
      res.status(200).json({
        access_token: result.accessToken,
        expires_at: new Date(expiresAt).toLocaleString(),
        expires_in: env.jwt.accessTtlSeconds,
      });
    } catch (e) {
      next(e);
    }
  });

  router.post("/auth/refresh", async (req, res, next) => {
    try {
      const rt = req.cookies?.rt ?? null;

      const result = await refresh(db, env, rt, { userAgent: req.get("user-agent") ?? null, ip: req.ip ?? null });

      res.cookie("rt", result.newRefreshToken, {
        httpOnly: true,
        secure: false,
        sameSite: "lax",
        path: "/auth",
      });

      const expiresAt = momentTimezone().toDate().getTime() + env.jwt.accessTtlSeconds * 1000;
      res.status(200).json({
        access_token: result.accessToken,
        expires_at: new Date(expiresAt).toLocaleString(),
        expires_in: env.jwt.accessTtlSeconds,
      });
    } catch (e) {
      next(e);
    }
  });

  router.post("/auth/logout", async (req, res, next) => {
    try {
      const rt = req.cookies?.rt ?? null;
      await logout(db, rt);

      res.clearCookie("rt", { path: "/auth" });
      res.sendStatus(204);
    } catch (e) {
      next(e);
    }
  });

  return router;
}
