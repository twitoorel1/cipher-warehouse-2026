import { Router } from "express";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { requireRoleOrPermission } from "@middleware/rbac.middleware.js";
import { createDevicesController } from "@controllers/devices.controller.js";
import { Roles } from "@/types/auth.js";
import { requirePermission } from "@middleware/requirePermission.middleware.js";
import { Permissions } from "@/types/permissions.js";

export function createDevicesRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const controller = createDevicesController(pool);

  router.get("/", requirePermission(Permissions.DEVICES_READ), controller.list);
  router.get("/by-id/:id", requirePermission(Permissions.DEVICES_READ), controller.getById);
  router.get("/by-serial/:serial", requirePermission(Permissions.DEVICES_READ), controller.getBySerial);

  router.patch("/by-id/:id", requirePermission(Permissions.DEVICES_UPDATE), controller.updateById);

  router.get("/tel100", requirePermission(Permissions.TEL100_VOICE_PROFILE_READ), controller.getTell100Devices);

  router.get("/tel100/:id/voice-profile", requirePermission(Permissions.DEVICES_READ), controller.getTel100VoiceProfile);
  router.get("/tel100/:id/modem-profile", requirePermission(Permissions.DEVICES_READ), controller.getTel100ModemProfile);

  return router;
}
