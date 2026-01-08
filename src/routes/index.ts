import express from "express";
import formatUptime from "../utils/dates.util.js";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { createAuthMiddleware } from "../middleware/auth.middleware.js";

async function dbPing(pool: Pool, timeoutMs: number) {
  const ping = pool.query("SELECT 1");
  const timeout = new Promise((_, rej) => setTimeout(() => rej(new Error("DB_PING_TIMEOUT")), timeoutMs));
  await Promise.race([ping, timeout]);
}

import { createAuthRouter } from "./auth.routes.js";
// import { createUsersRouter } from "./users.routes.js";
import { createDevicesRouter } from "./devices.routes.js";
import { createImportsRouter } from "./imports.routes.js";
import { Roles } from "../types/auth.js";

export default function createMainRouter(pool: Pool, env: AppEnv) {
  const router = express.Router();
  const auth = createAuthMiddleware(pool, env.jwt.accessSecret);

  router.get("/", (_req, res) => {
    res.status(200).json({ status: "ok", uptime: formatUptime(process.uptime()) });
  });

  router.get("/health", async (_req, res) => {
    try {
      await dbPing(pool, 500); // קצר, לא “healthcheck כבד”
      res.status(200).json({ ok: true, db: "up" });
    } catch {
      res.status(503).json({ ok: false, db: "down" });
    }
  });

  router.use("/auth", createAuthRouter(pool, env));
  // router.use("/users", auth, requireRole(Roles.ADMIN), createUsersRouter(pool, env));
  router.use("/devices", auth, createDevicesRouter(pool, env));
  router.use("/imports", auth, createImportsRouter(pool, env));

  return router;
}
