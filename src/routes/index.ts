import express from "express";
import formatUptime from "../utils/dates.util.js";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { createAuthMiddleware } from "../middleware/auth.middleware.js";

import { createAuthRouter } from "./auth.routes.js";
// import { createUsersRouter } from "./users.routes.js";
import { createDevicesRouter } from "./devices.routes.js";
import { createImportsRouter } from "./imports.routes.js";
import { Roles } from "../types/auth.js";

export default function createMainRouter(pool: Pool, env: AppEnv) {
  const router = express.Router();
  const auth = createAuthMiddleware(env);

  router.get("/", (_req, res) => {
    res.status(200).json({ status: "ok", uptime: formatUptime(process.uptime()) });
  });

  router.use("/auth", createAuthRouter(pool, env));
  // router.use("/users", auth, requireRole(Roles.ADMIN), createUsersRouter(pool, env));
  router.use("/devices", auth, createDevicesRouter(pool, env));
  router.use("/imports", auth, createImportsRouter(pool, env));

  return router;
}
