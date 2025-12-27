import type { Request, Response, NextFunction } from "express";
import { AppError } from "./error.middleware.js";
import { Roles, type AuthUser } from "../types/auth.js";

/**
 * Dynamic hierarchy based on enum order.
 * Requirement:
 * - Roles enum is ordered from HIGHEST -> LOWEST for battalion roles.
 * - ADMIN is excluded from hierarchy and always bypasses.
 */
function getHierarchyExcludingAdmin(): Roles[] {
  return (Object.values(Roles) as Roles[]).filter((r) => r !== Roles.ADMIN);
}

/**
 * Rank: 0 = highest, larger = lower.
 */
function getRank(role: Roles, hierarchy: Roles[]): number {
  return hierarchy.indexOf(role);
}

/**
 * ADMIN-only middleware.
 */
export function requireAdmin() {
  return function rbacAdmin(req: Request, _res: Response, next: NextFunction) {
    const user = req.user as AuthUser | undefined;

    if (!user) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
      return;
    }

    if (user.role !== Roles.ADMIN) {
      next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
      return;
    }

    next();
  };
}

/**
 * Hierarchical RBAC:
 * requireRole(MIN_ROLE) => MIN_ROLE and higher (based on enum order).
 *
 * Examples:
 * - requireRole(BATTALION_SOLDIER) => Soldier/NCO/Deputy/Chief (everyone)
 * - requireRole(BATTALION_NCO) => NCO/Deputy/Chief
 * - requireRole(BATTALION_CHIEF_OFFICER) => Chief only (excluding ADMIN bypass)
 */
export function requireRole(minRole: AuthUser["role"]) {
  return function rbacAtLeast(req: Request, _res: Response, next: NextFunction) {
    const user = req.user as AuthUser | undefined;

    if (!user) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
      return;
    }

    // ADMIN always bypasses everything
    if (user.role === Roles.ADMIN) {
      next();
      return;
    }

    const hierarchy = getHierarchyExcludingAdmin();

    const userRank = getRank(user.role as Roles, hierarchy);
    const minRank = getRank(minRole as Roles, hierarchy);

    // If role not found in hierarchy => forbid (guards misconfig)
    if (userRank === -1 || minRank === -1) {
      next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
      return;
    }

    // With 0=highest:
    // user must be <= minRank to be "minRole or higher"
    if (userRank > minRank) {
      next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
      return;
    }

    next();
  };
}

/**
 * Exact RBAC (no hierarchy):
 * requireAnyRole(A, B, C) => user.role must be exactly one of them.
 *
 * Example:
 * - requireAnyRole(BATTALION_SOLDIER, BATTALION_NCO)
 *   => ONLY soldier or nco, deputy/chief blocked (ADMIN bypasses).
 */
export function requireAnyRole(...roles: AuthUser["role"][]) {
  return function rbacAny(req: Request, _res: Response, next: NextFunction) {
    const user = req.user as AuthUser | undefined;

    if (!user) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
      return;
    }

    // ADMIN always bypasses everything
    if (user.role === Roles.ADMIN) {
      next();
      return;
    }

    if (!roles.includes(user.role)) {
      next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
      return;
    }

    next();
  };
}

// OLDER CODE:
// import type { Request, Response, NextFunction } from "express";
// import { AppError } from "./error.middleware.js";
// import { Roles, type AuthUser } from "../types/auth.js";

// export function requireRole(...allowed: AuthUser["role"][]) {
//   return function rbac(req: Request, res: Response, next: NextFunction) {
//     const user = req.user;
//     if (!user) {
//       next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
//       return;
//     }

//     if (user.role === Roles.ADMIN) {
//       next();
//       return;
//     }

//     if (!allowed.includes(user.role)) {
//       next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
//       return;
//     }

//     next();
//   };
// }
