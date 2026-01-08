import type { Request, Response, NextFunction } from "express";
import { can } from "@/rbac/can.js";
import { Permissions } from "@/types/permissions.js";
import { AppError } from "./error.middleware.js";

export function requirePermission(permission: Permissions) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) {
      return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
    }

    if (!can(user, permission)) {
      return next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
    }

    next();
  };
}
