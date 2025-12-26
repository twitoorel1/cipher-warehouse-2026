import type { Request, Response, NextFunction } from "express";
import { AppError } from "./error.middleware.js";
import { Roles, type AuthUser } from "../types/auth.js";

export function requireRole(...allowed: AuthUser["role"][]) {
  return function rbac(req: Request, res: Response, next: NextFunction) {
    const user = req.user;
    if (!user) {
      next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
      return;
    }

    if (user.role === Roles.ADMIN) {
      next();
      return;
    }

    if (!allowed.includes(user.role)) {
      next(new AppError({ code: "FORBIDDEN", status: 403, message: "Forbidden" }));
      return;
    }

    next();
  };
}
