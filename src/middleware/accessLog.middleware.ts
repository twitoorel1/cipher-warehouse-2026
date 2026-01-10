import type { Request, Response, NextFunction } from "express";
import { log } from "../utils/logger.js";

function pickIp(req: Request): string | null {
  const ip = req.ip || (req.connection as any)?.remoteAddress || null;
  return typeof ip === "string" ? ip : null;
}

export function accessLog() {
  return (req: Request, res: Response, next: NextFunction) => {
    const start = process.hrtime.bigint();

    res.on("finish", () => {
      const end = process.hrtime.bigint();
      const durationMs = Number(end - start) / 1_000_000;

      // Health endpoints can be noisy; keep them lower severity.
      const path = req.path;
      const level = path === "/health" ? "debug" : "info";

      const requestId = (req as any).requestId as string | undefined;

      log(level as any, "http_request", {
        requestId,
        userId: req.user?.id,
        method: req.method,
        path,
        status: res.statusCode,
        durationMs: Math.round(durationMs * 1000) / 1000,
        ip: pickIp(req),
        userAgent: req.get("user-agent") || null,
      });
    });

    next();
  };
}
