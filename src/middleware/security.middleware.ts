import helmet from "helmet";
import type { Express } from "express";

export function harden(app: Express) {
  app.disable("x-powered-by");

  const isProd = process.env.NODE_ENV === "production";
  const corsOrigins = (process.env.CORS_ORIGINS || "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);

  app.use(
    helmet({
      contentSecurityPolicy: isProd
        ? {
            useDefaults: true,
            directives: {
              "default-src": ["'self'"],
              "script-src": ["'self'"],
              "style-src": ["'self'"],
              "img-src": ["'self'", "data:"],
              "connect-src": ["'self'", ...corsOrigins],
              "font-src": ["'self'"],
              "object-src": ["'none'"],
              "media-src": ["'self'"],
              "base-uri": ["'self'"],
              "frame-ancestors": ["'none'"],
              "form-action": ["'self'"],
              // אם יש צורך לאפשר העלאת תמונות/פונטים חיצוניים, הוסף כאן מקורות
              // אם משתמשים ב-WebSocket: אפשר גם "wss:" ב-connect-src
              // "upgrade-insecure-requests": []  // הפעל אם מגישים רק HTTPS
            },
          }
        : false,
      referrerPolicy: { policy: "no-referrer" },
      // אם יש תוכן משותף בין מקורות, שקול להתאים:
      // crossOriginResourcePolicy: { policy: "cross-origin" },
    })
  );
}
