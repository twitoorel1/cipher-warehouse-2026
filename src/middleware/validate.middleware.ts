import type { Request, Response, NextFunction } from "express";
import type { ZodType } from "zod";
import { AppError } from "./error.middleware.js";

type Target = "body" | "query" | "params";

export function validate(schema: ZodType, target: Target = "body") {
  return function validateMiddleware(req: Request, _res: Response, next: NextFunction) {
    const data = (req as any)[target];
    const result = schema.safeParse(data);

    if (!result.success) {
      next(
        new AppError({
          code: "VALIDATION_ERROR",
          status: 400,
          message: "Validation failed",
          details: result.error.flatten(),
        })
      );
      return;
    }

    (req as any)[target] = result.data;
    next();
  };
}
