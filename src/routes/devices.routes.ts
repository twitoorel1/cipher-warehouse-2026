import { Router } from "express";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { createAuthMiddleware } from "../middleware/auth.middleware.js";
import { requireRole } from "../middleware/rbac.middleware.js";
import { createDevicesController } from "../controllers/devices.controller.js";
import { Roles } from "../types/auth.js";

// Olders
export function createDevicesRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const auth = createAuthMiddleware(env);
  const controller = createDevicesController(pool);

  router.get("/devices/by-serial/:serial", auth, controller.getBySerial);

  // router.get("/devices", auth, requireRole(Roles.ADMIN), controller.list);
  // router.get("/devices/:id", auth, requireRole(Roles.ADMIN), controller.getById);

  return router;
}
