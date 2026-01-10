import type { Request, Response, NextFunction } from "express";
import { log, reqBaseMeta, safeErrorMeta } from "@utils/logger.js";

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
  res.status(404).json({
    code: "NOT_FOUND",
    message: "Route not found",
    path: req.path,
  });
}

function isProd() {
  return process.env.NODE_ENV === "production";
}

export function errorHandler(err: unknown, req: Request, res: Response, next: NextFunction) {
  if (res.headersSent) return next(err);

  const base = reqBaseMeta(req);

  if (err instanceof AppError) {
    log("warn", "app_error", {
      ...base,
      code: err.code,
      status: err.status,
      ...(isProd() ? {} : { details: err.details }),
    });

    const safeDetails = !isProd() ? err.details : err.code === "VALIDATION_ERROR" ? err.details : undefined;

    res.status(err.status).json({
      code: err.code,
      message: err.message,
      ...(safeDetails ? { details: safeDetails } : {}),
    });
    return;
  }

  log("error", "unhandled_error", {
    ...base,
    ...safeErrorMeta(err),
  });

  res.status(500).json({
    code: "INTERNAL_ERROR",
    message: "Internal error",
  });

  // // Minimal internal logging (no leak to client)
  // // מומלץ לשלב כאן logger אמיתי אם יש לך (pino/winston)
  // const baseLog = {
  //   method: req.method,
  //   path: req.path,
  // };

  // if (err instanceof AppError) {
  //   if (isProd()) {
  //     console.error("AppError:", { ...baseLog, code: err.code, status: err.status });
  //   } else {
  //     console.error("AppError:", { ...baseLog, code: err.code, status: err.status, details: err.details });
  //   }

  //   const safeDetails = !isProd() ? err.details : err.code === "VALIDATION_ERROR" ? err.details : undefined;

  //   res.status(err.status).json({
  //     code: err.code,
  //     message: err.message,
  //     ...(safeDetails ? { details: safeDetails } : {}),
  //   });
  //   return;
  // }

  // console.error("Unhandled error:", { ...baseLog, err });

  // res.status(500).json({
  //   code: "INTERNAL_ERROR",
  //   message: "Internal error",
  // });
}
