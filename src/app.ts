import express from "express";
import cookieParser from "cookie-parser";
import cors from "cors";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import type { Pool } from "mysql2/promise";
import { rateLimit } from "./middleware/rateLimit.middleware.js";
import { errorHandler, notFoundHandler } from "./middleware/error.middleware.js";
import type { AppEnv } from "./config/env.js";
import momentTimezone from "moment-timezone";
import { harden } from "./middleware/security.middleware.js";
import createMainRouter from "./routes/index.js";

export const createApp = (env: AppEnv, pool: Pool) => {
  const app = express();
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);

  // Time Zone
  momentTimezone.tz.setDefault("Asia/Jerusalem");

  // Check if public directory exists
  if (!fs.existsSync(path.join(__dirname, "public"))) {
    fs.mkdirSync(path.join(__dirname, "public"));
  }

  // Middlewares
  harden(app);
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

  app.use(express.static(path.join(__dirname, "public")));
  app.use(rateLimit());
  app.use(express.json({ limit: "1mb" }));
  app.use(express.raw());
  app.use(express.urlencoded({ extended: true, limit: "1mb" }));
  app.use(cookieParser());

  app.use(createMainRouter(pool, env));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
