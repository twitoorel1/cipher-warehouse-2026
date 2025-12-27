import type { Request, Response, NextFunction } from "express";
import { jwtVerify } from "jose";
import { AppError } from "./error.middleware.js";
import type { AppEnv } from "../config/env.js";
import { Roles } from "../types/auth.js";

export function createAuthMiddleware(env: AppEnv) {
  const key = new TextEncoder().encode(env.jwt.accessSecret);

  return async function authMiddleware(req: Request, res: Response, next: NextFunction) {
    const auth = req.get("authorization") ?? "";
    const m = auth.match(/^Bearer\s+(.+)$/i);
    let token = m?.[1] ?? null;

    if (!token && (req as any).cookies?.access_token) {
      token = (req as any).cookies.access_token;
    }

    if (!token) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Missing access token" }));
      return;
    }

    try {
      const verifyOptions: Parameters<typeof jwtVerify>[2] = {
        algorithms: ["HS256"],
        clockTolerance: "5s",
      };
      if (env.jwt.issuer) verifyOptions.issuer = env.jwt.issuer;
      if (env.jwt.audience) verifyOptions.audience = env.jwt.audience;

      // const key = new TextEncoder().encode(env.jwt.accessSecret);
      const { payload } = await jwtVerify(token, key, verifyOptions);

      const sub = payload.sub;
      const role = payload.role;

      if (typeof sub !== "string") {
        return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
      }

      if (typeof role !== "string" || !(Object.values(Roles) as string[]).includes(role)) {
        return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
      }

      const userId = Number(sub);
      if (!Number.isFinite(userId) || userId <= 0) {
        return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
      }

      req.user = { id: userId, role: role as Roles };
      return next();
    } catch (error: any) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid or expired token" }));
    }
  };
}
