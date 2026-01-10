import type { Request, Response, NextFunction } from "express";
import { BoundedTtlCache } from "@/utils/boundedTtlCache.js";

type Entry = { count: number; resetAt: number };

export function rateLimit(options?: { windowMs?: number; max?: number }) {
  const windowMs = options?.windowMs ?? 60_000; // 1 minute
  const max = options?.max ?? 300; // 300 requests per windowMs

  /**
   * Hardening: prevent unbounded growth by bounding entries and expiring them.
   * - TTL aligned to the window
   * - Max size cap (defensive against IP churn / abuse)
   * - Opportunistic sweeps (no interval)
   */

  // const store = new Map<string, Entry>();
  const store = new BoundedTtlCache<string, Entry>({
    defaultTtlMs: windowMs,
    maxSize: 20_000,
    sweepIntervalMs: 30_000,
  });

  return function rateLimitMiddleware(req: Request, res: Response, next: NextFunction) {
    const ip = (req.headers["x-forwarded-for"] as string | undefined)?.split(",")[0]?.trim() || req.socket.remoteAddress || "unknown";
    const now = Date.now();
    const existing = store.get(ip, now);

    if (!existing || existing.resetAt <= now) {
      store.set(ip, { count: 1, resetAt: now + windowMs }, windowMs, now);
      return next();
    }

    existing.count += 1;

    // Refresh TTL so the entry naturally falls out shortly after the window ends.
    store.set(ip, existing, existing.resetAt - now, now);

    if (existing.count > max) {
      res.status(429).json({ code: "RATE_LIMITED", message: "Too many requests" });
      return;
    }

    next();
  };
}
