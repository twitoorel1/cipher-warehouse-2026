import type { Request, Response, NextFunction } from "express";
import { jwtVerify } from "jose";
import type { Pool } from "mysql2/promise";
import { z } from "zod";
import { AppError } from "./error.middleware.js";
import { PermissionOverride, Roles } from "../types/auth.js";
import { loadPermissionOverridesCached } from "@services/auth/permissionOverrides.service.js";

/**
 * ===== Payload validation =====
 * מוודא שה-JWT לא מכיל שטויות / role מזויף
 */
const accessTokenPayloadSchema = z.object({
  role: z.nativeEnum(Roles),
  battalion_id: z.number().int().nullable().optional(),
  division_id: z.number().int().nullable().optional(),
});

/**
 * ===== טיפוס המשתמש שיוזרק ל-req =====
 */
export type AuthenticatedUser = {
  userId: number;
  role: Roles;
  battalion_id?: number | null;
  division_id?: number | null;
  permissionOverrides: PermissionOverride[];
};
/**
 * ===== Middleware ראשי =====
 * - מאמת Bearer token
 * - מאמת JWT (signature + exp)
 * - מאמת payload (role, ids)
 * - טוען permission overrides עם cache
 */
export function createAuthMiddleware(pool: Pool, accessTokenSecret: string) {
  const key = new TextEncoder().encode(accessTokenSecret);

  return async function authMiddleware(req: Request, _res: Response, next: NextFunction) {
    try {
      /**
       * ===== שלב 1: חילוץ Authorization header =====
       */
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new AppError({
          code: "UNAUTHORIZED",
          status: 401,
          message: "Missing or invalid Authorization header",
        });
      }

      const token = authHeader.slice("Bearer ".length).trim();
      if (!token) {
        throw new AppError({
          code: "UNAUTHORIZED",
          status: 401,
          message: "Missing access token",
        });
      }

      /**
       * ===== שלב 2: אימות JWT =====
       * - חתימה
       * - exp
       * - clockTolerance מונע נפילות על clock skew קטן
       */
      const { payload } = await jwtVerify(token, key, {
        algorithms: ["HS256"],
        clockTolerance: "5s",
        // אם תרצה בעתיד:
        // issuer: env.jwt.issuer,
        // audience: env.jwt.audience,
      });

      /**
       * ===== שלב 3: אימות subject (userId) =====
       */
      const userId = Number(payload.sub);
      if (!Number.isInteger(userId) || userId <= 0) {
        throw new AppError({
          code: "UNAUTHORIZED",
          status: 401,
          message: "Invalid token subject",
        });
      }

      /**
       * ===== שלב 4: אימות payload (role + scope IDs) =====
       */
      const parsed = accessTokenPayloadSchema.safeParse(payload);
      if (!parsed.success) {
        throw new AppError({
          code: "UNAUTHORIZED",
          status: 401,
          message: "Invalid token payload",
        });
      }

      const { role, battalion_id, division_id } = parsed.data;

      /**
       * ===== שלב 5: טעינת Permission Overrides (עם cache TTL) =====
       */
      const permissionOverrides = await loadPermissionOverridesCached(pool, userId);

      /**
       * ===== שלב 6: הצמדת user ל-req =====
       * מכאן והלאה כל המערכת סומכת על זה
       */
      const user: AuthenticatedUser = {
        userId,
        role,
        battalion_id: battalion_id ?? null,
        division_id: division_id ?? null,
        permissionOverrides,
      };

      (req as any).user = user;

      next();
    } catch (err) {
      /**
       * ===== כל שגיאת auth → 401 =====
       * לא מדליפים מידע
       */
      if (err instanceof AppError) {
        return next(err);
      }

      return next(
        new AppError({
          code: "UNAUTHORIZED",
          status: 401,
          message: "Unauthorized",
        })
      );
    }
  };
}
