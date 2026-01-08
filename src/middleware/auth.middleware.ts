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

// import type { Request, Response, NextFunction } from "express";
// import { jwtVerify } from "jose";
// import type { Pool } from "mysql2/promise";
// import { AppError } from "./error.middleware.js";
// import { Roles } from "../types/auth.js";
// import type { AuthUser } from "../types/auth.js";

// // עדיף import יחסי (אם ה-path alias שלך עובד, אפשר להשאיר את שלך)
// import { listUserPermissionOverrides } from "../db/queries/permissions.queries.js";

// type OverrideEffect = "ALLOW" | "DENY";

// function toOverrideEffect(v: unknown): OverrideEffect {
//   return String(v).trim().toUpperCase() === "DENY" ? "DENY" : "ALLOW";
// }

// const encoder = new TextEncoder();

// // =========================
// // Overrides Cache (TTL)
// // =========================
// type CachedOverrides = {
//   fetchedAtMs: number;
//   overrides: { permission: string; effect: OverrideEffect }[];
// };

// const OVERRIDES_TTL_MS = 30_000; // 30 שניות (תוכל לשנות ל-60_000)
// const OVERRIDES_CACHE_MAX = 5_000;

// const overridesCache = new Map<number, CachedOverrides>();

// function cacheGet(userId: number): CachedOverrides | null {
//   const hit = overridesCache.get(userId);
//   if (!hit) return null;

//   const age = Date.now() - hit.fetchedAtMs;
//   if (age > OVERRIDES_TTL_MS) {
//     overridesCache.delete(userId);
//     return null;
//   }

//   // LRU: להזיז לסוף
//   overridesCache.delete(userId);
//   overridesCache.set(userId, hit);

//   return hit;
// }

// function cacheSet(userId: number, value: CachedOverrides) {
//   overridesCache.set(userId, value);

//   // LRU eviction
//   if (overridesCache.size > OVERRIDES_CACHE_MAX) {
//     const oldestKey = overridesCache.keys().next().value as number | undefined;
//     if (oldestKey !== undefined) overridesCache.delete(oldestKey);
//   }
// }

// // שימושי לשלב A (ניהול overrides): נוכל לקרוא לזה אחרי שינוי הרשאות
// export function invalidateUserOverridesCache(userId?: number) {
//   if (typeof userId === "number") overridesCache.delete(userId);
//   else overridesCache.clear();
// }

// async function getOverridesWithCache(pool: Pool, userId: number) {
//   const hit = cacheGet(userId);
//   if (hit) return hit.overrides;

//   const rows = await listUserPermissionOverrides(pool, userId);

//   const overrides = rows.map((r) => ({
//     permission: String(r.permission).trim(),
//     effect: toOverrideEffect(r.effect),
//   }));

//   cacheSet(userId, { fetchedAtMs: Date.now(), overrides });
//   return overrides;
// }

// export function createAuthMiddleware(pool: Pool, secret: string) {
//   const key = encoder.encode(secret);

//   return async function auth(req: Request, _res: Response, next: NextFunction) {
//     try {
//       const header = req.headers.authorization;
//       if (!header || !header.startsWith("Bearer ")) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Missing token" }));
//       }

//       const token = header.slice("Bearer ".length).trim();

//       const { payload } = await jwtVerify(token, key, {
//         algorithms: ["HS256"],
//       });

//       // --- Basic fields ---
//       const userId = Number(payload.sub);
//       const role = payload.role as Roles;

//       if (!Number.isFinite(userId) || userId <= 0) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       if (!role || !(Object.values(Roles) as string[]).includes(role)) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       // --- Scope fields ---
//       const battalion_id = payload.battalion_id === null || payload.battalion_id === undefined ? null : Number(payload.battalion_id);
//       const division_id = payload.division_id === null || payload.division_id === undefined ? null : Number(payload.division_id);

//       if (battalion_id !== null && (!Number.isFinite(battalion_id) || battalion_id <= 0)) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       if (division_id !== null && (!Number.isFinite(division_id) || division_id <= 0)) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       // --- Scope vs Role validation ---
//       if (role.startsWith("BATTALION_") && battalion_id === null) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       if (role.startsWith("DIVISION_") && division_id === null) {
//         return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid token" }));
//       }

//       // ✅ fetch overrides (cached)
//       const permissionOverrides = await getOverridesWithCache(pool, userId);

//       (req as any).user = {
//         id: userId,
//         role,
//         battalion_id,
//         division_id,
//         permissionOverrides,
//       } satisfies AuthUser;

//       return next();
//     } catch {
//       return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid or expired token" }));
//     }
//   };
// }
