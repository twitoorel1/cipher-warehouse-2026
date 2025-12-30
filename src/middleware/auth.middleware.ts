import type { Request, Response, NextFunction } from "express";
import { jwtVerify } from "jose";
import { AppError } from "./error.middleware.js";
import type { AppEnv } from "../config/env.js";
import { Roles } from "../types/auth.js";
import type { AuthUser } from "../types/auth.js";

const encoder = new TextEncoder();

export function createAuthMiddleware(secret: string) {
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

      const user: AuthUser = {
        id: userId,
        role,
        battalion_id,
        division_id,
      };

      req.user = user;
      return next();
    } catch (err) {
      return next(new AppError({ status: 401, code: "UNAUTHORIZED", message: "Invalid or expired token" }));
    }
  };
}

// OLDER
// export function createAuthMiddleware_OLD(env: AppEnv) {
//   const key = new TextEncoder().encode(env.jwt.accessSecret);

//   return async function authMiddleware(req: Request, res: Response, next: NextFunction) {
//     const auth = req.get("authorization") ?? "";
//     const m = auth.match(/^Bearer\s+(.+)$/i);
//     let token = m?.[1] ?? null;

//     if (!token && (req as any).cookies?.access_token) {
//       token = (req as any).cookies.access_token;
//     }

//     if (!token) {
//       next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Missing access token" }));
//       return;
//     }

//     try {
//       const verifyOptions: Parameters<typeof jwtVerify>[2] = {
//         algorithms: ["HS256"],
//         clockTolerance: "5s",
//       };
//       if (env.jwt.issuer) verifyOptions.issuer = env.jwt.issuer;
//       if (env.jwt.audience) verifyOptions.audience = env.jwt.audience;

//       // const key = new TextEncoder().encode(env.jwt.accessSecret);
//       const { payload } = await jwtVerify(token, key, verifyOptions);

//       const sub = payload.sub;
//       const role = payload.role;

//       const battalion_id = typeof payload.battalion_id === "number" ? payload.battalion_id : null;
//       const division_id = typeof payload.division_id === "number" ? payload.division_id : null;

//       if (typeof sub !== "string") {
//         return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
//       }

//       if (typeof role !== "string" || !(Object.values(Roles) as string[]).includes(role)) {
//         return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
//       }

//       const userId = Number(sub);
//       if (!Number.isFinite(userId) || userId <= 0) {
//         return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid token" }));
//       }

//       req.user = { id: userId, role: role as Roles, battalion_id: battalion_id, division_id: division_id };
//       return next();
//     } catch (error: any) {
//       next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Invalid or expired token" }));
//     }
//   };
// }
