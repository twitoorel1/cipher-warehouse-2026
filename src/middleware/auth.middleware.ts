import type { Request, Response, NextFunction } from "express";
import { jwtVerify } from "jose";
import { AppError } from "./error.middleware.js";
import type { AppEnv } from "../config/env.js";
import { Roles } from "../types/auth.js";

export function createAuthMiddleware(env: AppEnv) {
  return async function authMiddleware(req: Request, res: Response, next: NextFunction) {
    const auth = req.get("authorization") ?? "";
    const m = auth.match(/^Bearer\s+(.+)$/i);
    const token = m?.[1] ?? null;

    if (!token) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Missing access token" }));
    }

    try {
      const key = new TextEncoder().encode(env.jwt.accessSecret);
      const { payload } = await jwtVerify(token!, key, { algorithms: ["HS256"] });

      const sub = payload.sub;
      const role = payload.role;

      if (typeof sub !== "string") {
        next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
        return;
      }

      if (role !== Roles.VIEWER && role !== Roles.EDITOR && role !== Roles.ADMIN) {
        next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
        return;
      }

      const userId = Number(sub);
      if (!Number.isFinite(userId) || userId <= 0) {
        next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
        return;
      }

      req.user = { id: userId, role };
      next();
    } catch (error: any) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid or expired token" }));
    }
  };
}
