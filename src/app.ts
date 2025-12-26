import express from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import type { Pool } from "mysql2/promise";
import { rateLimit } from "./middleware/rateLimit.middleware.js";
import { errorHandler, notFoundHandler } from "./middleware/error.middleware.js";
import type { AppEnv } from "./config/env.js";
import momentTimezone from "moment-timezone";

// Routes
import { createAuthRouter } from "./routes/auth.routes.js";
import { createDevicesRouter } from "./routes/devices.routes.js";
import { createImportsRouter } from "./routes/imports.routes.js";

export const createApp = (env: AppEnv, pool: Pool) => {
  const app = express();

  // Time Zone
  momentTimezone.tz.setDefault("Asia/Jerusalem");

  // Middlewares
  app.use(
    cors({
      origin: (origin, cb) => {
        if (!origin) return cb(null, true);
        if (env.corsOrigins.includes(origin)) return cb(null, true);
        return cb(new Error("CORS blocked"), false);
      },
      credentials: true,
    })
  );

  app.use(rateLimit());
  app.use(express.json({ limit: "1mb" }));
  app.use(cookieParser());

  app.use(createAuthRouter(pool, env));
  app.use(createDevicesRouter(pool, env));
  app.use(createImportsRouter(pool, env));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
