import type { Request, Response, NextFunction } from "express";
import { log } from "@utils/logger.js";

type AuditOptions = {
  /**
   * נתיבים שמייצרים רעש (ברירת מחדל: health/metrics)
   */
  ignorePaths?: string[];
  /**
   * אם request איטי יותר מהסף הזה (ms) – יוציא warn בנוסף ל-audit
   */
  slowRequestThresholdMs?: number;
};

function isWriteMethod(method: string) {
  return method === "POST" || method === "PUT" || method === "PATCH" || method === "DELETE";
}

function normalizePath(req: Request) {
  // originalUrl כולל query; אנחנו רוצים path נקי
  const url = req.originalUrl || req.url || "";
  const q = url.indexOf("?");
  return q >= 0 ? url.slice(0, q) : url;
}

function getIp(req: Request) {
  const xf = req.headers["x-forwarded-for"];
  if (typeof xf === "string" && xf.length) return xf.split(",")[0]?.trim();
  return req.ip || (req.socket && req.socket.remoteAddress) || "";
}

function pickResourceId(req: Request) {
  // מנסה למצוא מזהה משאב נפוץ בלי לנחש business logic
  // אם יש params כמו :id או :deviceId וכו' — נרשום את הראשון שנמצא
  const params = req.params || {};
  const preferredKeys = ["id", "deviceId", "userId", "overrideId", "importId"];
  for (const k of preferredKeys) {
    const v = (params as any)[k];
    if (v !== undefined && v !== null && String(v).length) return { key: k, value: String(v) };
  }
  // fallback: כל param ראשון
  const first = Object.entries(params)[0];
  if (first) return { key: first[0], value: String(first[1]) };
  return undefined;
}

/**
 * Audit ל-Write Paths בלבד.
 * - לא רושם body
 * - לא רושם headers
 * - מקושר ל-requestId שכבר נוצר ב-requestContext middleware
 */
export function auditWritePaths(opts: AuditOptions = {}) {
  const ignore = new Set(opts.ignorePaths ?? ["/health", "/metrics"]);
  const slowThreshold = typeof opts.slowRequestThresholdMs === "number" ? opts.slowRequestThresholdMs : 1200;

  return (req: Request, res: Response, next: NextFunction) => {
    if (!isWriteMethod(req.method)) return next();

    const path = normalizePath(req);
    if (ignore.has(path)) return next();

    const start = process.hrtime.bigint();

    res.on("finish", () => {
      const end = process.hrtime.bigint();
      const durationMs = Number(end - start) / 1_000_000;

      const requestId = (req as any).requestId as string | undefined;
      const userId = (req as any).user?.id ?? (req as any).userId;

      const resource = pickResourceId(req);

      const baseFields = {
        requestId,
        userId,
        method: req.method,
        path,
        status: res.statusCode,
        durationMs: Math.round(durationMs),
        ip: getIp(req),
        // userAgent כן שימושי לחקירה, לא רגיש בדרך כלל
        userAgent: req.headers["user-agent"],
        resourceKey: resource?.key,
        resourceId: resource?.value,
      };

      // Audit event — תמיד info
      log("info", "audit_write", baseFields);

      // Slow write-path — warn (אופציונלי)
      if (durationMs >= slowThreshold) {
        log("warn", "slow_write", {
          ...baseFields,
          thresholdMs: slowThreshold,
        });
      }
    });

    next();
  };
}
