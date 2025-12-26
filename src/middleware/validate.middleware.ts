import type { Request, Response, NextFunction } from "express";
import type { ZodType } from "zod";

type Target = "body" | "query" | "params";

export function validate(schema: ZodType, target: Target = "body") {
  return function validateMiddleware(req: Request, res: Response, next: NextFunction) {
    const data = (req as any)[target];
    const result = schema.safeParse(data);

    if (!result.success) {
      res.status(400).json({
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: result.error.flatten()
      });
      return;
    }

    (req as any)[target] = result.data;
    next();
  };
}
