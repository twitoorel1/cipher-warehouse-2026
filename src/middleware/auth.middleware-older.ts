import type { Request, Response, NextFunction } from "express";
import { jwtVerify } from "jose";
import { AppError } from "./error.middleware.js";
import type { AppEnv } from "../config/env.js";
import { Roles } from "../types/auth.js";
import type { AuthUser } from "../types/auth.js";
import type { Pool } from "mysql2/promise";
import { listUserPermissionOverrides } from "@/db/queries/permissions.queries.js";

const encoder = new TextEncoder();

export function createAuthMiddleware(pool: Pool, secret: string) {
  const key = encoder.encode(secret);

  return async function auth(req: Request, _res: Response, next: NextFunction) {
    try {
      const header = req.headers.authorization;
      if (!header || !header.startsWith("Bearer ")) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Missing token" }));
      }

      const token = header.slice("Bearer ".length).trim();

      const { payload } = await jwtVerify(token, key, {
        algorithms: ["HS256"],
      });

      // --- Basic fields ---
      const userId = Number(payload.sub);
      const role = payload.role as Roles;

      if (!Number.isFinite(userId) || userId <= 0) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      if (!role || !(Object.values(Roles) as string[]).includes(role)) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      // --- Scope fields ---
      const battalion_id = payload.battalion_id === null || payload.battalion_id === undefined ? null : Number(payload.battalion_id);
      const division_id = payload.division_id === null || payload.division_id === undefined ? null : Number(payload.division_id);

      if (battalion_id !== null && (!Number.isFinite(battalion_id) || battalion_id <= 0)) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      if (division_id !== null && (!Number.isFinite(division_id) || division_id <= 0)) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      // --- Scope vs Role validation ---
      if (role.startsWith("BATTALION_") && battalion_id === null) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      if (role.startsWith("DIVISION_") && division_id === null) {
        return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
      }

      // ADMIN: no scope required

      // ✅ fetch overrides from DB
      const rows = await listUserPermissionOverrides(pool, userId);

      const permissionOverrides = rows.map((r) => ({
        permission: String(r.permission),
        effect: r.effect,
      }));

      (req as any).user = {
        userId,
        role,
        battalion_id,
        division_id,
        permissionOverrides: rows.map((r) => ({
          permission: String(r.permission).trim(),
          effect: r.effect === "DENY" ? "DENY" : "ALLOW",
        })),
      };

      return next();
    } catch (err) {
      return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid or expired token" }));
    }
  };
}
