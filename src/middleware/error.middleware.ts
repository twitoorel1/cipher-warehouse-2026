import type { Request, Response, NextFunction } from "express";

export class AppError extends Error {
  code: string;
  status: number;
  details?: Record<string, unknown> | undefined;

  constructor(args: { code: string; message: string; status: number; details?: Record<string, unknown> | undefined }) {
    super(args.message);
    this.code = args.code;
    this.status = args.status;
    this.details = args.details;
  }
}

export function notFoundHandler(req: Request, res: Response) {
  res.status(404).json({ code: "NOT_FOUND", message: "Not found" });
}

export function errorHandler(err: unknown, req: Request, res: Response, next: NextFunction) {
  if (res.headersSent) return next(err);

  if (err instanceof AppError) {
    res.status(err.status).json({
      code: err.code,
      message: err.message,
      ...(err.details ? { details: err.details } : {}),
    });
    return;
  }

  res.status(500).json({ code: "INTERNAL_ERROR", message: "Internal error" });
}
