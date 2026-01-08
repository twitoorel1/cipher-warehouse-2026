import { Router } from "express";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { requireRoleOrPermission } from "@middleware/rbac.middleware.js";
import { createDevicesController } from "@controllers/devices.controller.js";
import { Roles } from "../types/auth.js";
import { requirePermission } from "@middleware/requirePermission.middleware.js";
import { Permissions } from "@/types/permissions.js";

export function createDevicesRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const controller = createDevicesController(pool);

  router.get("/", requirePermission(Permissions.DEVICES_READ), controller.list);
  router.get("/by-id/:id", requirePermission(Permissions.DEVICES_READ), controller.getById);
  router.get("/by-serial/:serial", requirePermission(Permissions.DEVICES_READ), controller.getBySerial);

  // router.get("/battery-life", auth, controller.getByBatteryLife);
  // router.patch("/update-by-id/:id", auth, controller.updateById);

  return router;
}
