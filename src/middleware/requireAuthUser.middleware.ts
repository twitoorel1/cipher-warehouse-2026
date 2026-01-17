import type { Request, Response, NextFunction } from "express";
import { AppError } from "./error.middleware.js";

export function requireAuthUser(req: Request, _res: Response, next: NextFunction) {
  if (!req.user) {
    return next(
      new AppError({
        code: "UNAUTHORIZED",
        status: 401,
        message: "Unauthorized",
      })
    );
  }
  next();
}
