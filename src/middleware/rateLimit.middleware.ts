import type { Request, Response, NextFunction } from 'express';

type Entry = { count: number; resetAt: number };
 
export function rateLimit(options?: { windowMs?: number; max?: number }) {
    const windowMs = options?.windowMs ?? 60_000; // 1 minute
    const max = options?.max ?? 300; // 300 requests per windowMs

    const store = new Map<string, Entry>();

  return function rateLimitMiddleware(req: Request, res: Response, next: NextFunction) {
     const ip = (req.headers["x-forwarded-for"] as string | undefined)?.split(",")[0]?.trim() || req.socket.remoteAddress || "unknown";
        const now = Date.now();
        const existing = store.get(ip);

        if(!existing || existing.resetAt <= now) {
            store.set(ip, { count: 1, resetAt: now + windowMs });
            return next();
        }

        existing.count += 1;

        if(existing.count > max) {
            res.status(429).json({ code: "RATE_LIMITED", message: "Too many requests" });
            return;
        }
        
        next();
  };
}

