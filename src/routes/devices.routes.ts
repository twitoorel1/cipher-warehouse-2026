import { Router } from "express";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { requireRoleOrPermission } from "@middleware/rbac.middleware.js";
import { createDevicesController } from "@controllers/devices.controller.js";
import { Roles } from "@/types/auth.js";
import { requirePermission } from "@middleware/requirePermission.middleware.js";
import { Permissions } from "@/types/permissions.js";
import { requireAuthUser } from "@/middleware/requireAuthUser.middleware.js";

export function createDevicesRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const controller = createDevicesController(pool);

  router.get("/", requirePermission(Permissions.DEVICES_READ), controller.list);
  router.get("/by-id/:id", requirePermission(Permissions.DEVICES_READ), controller.getById);
  router.get("/by-serial/:serial", requirePermission(Permissions.DEVICES_READ), controller.getBySerial);
  router.patch("/by-id/:id", requirePermission(Permissions.DEVICES_UPDATE), controller.updateById);

  router.get("/tel100", requirePermission(Permissions.TEL100_VOICE_PROFILE_READ), controller.getTel100Devices);

  router.get("/tel100/voice-profile/encrypt/:id", requirePermission(Permissions.TEL100_VOICE_PROFILE_READ), controller.getTel100VoiceProfile);
  router.post("/tel100/voice-profile/:id", requirePermission(Permissions.TEL100_VOICE_PROFILE_CREATE), controller.createTel100VoiceProfile);
  router.patch("/tel100/voice-profile", requireAuthUser, requirePermission(Permissions.TEL100_VOICE_PROFILE_UPDATE), controller.patchTel100VoiceProfile);
  router.get("/tel100/voice-profile/decrypt/:coreDeviceId", requireAuthUser, requirePermission(Permissions.TEL100_VOICE_VIEW), controller.getTel100VoiceProfileController);

  router.get("/tel100/modem-profile/encrypt/:id", requirePermission(Permissions.TEL100_MODEM_PROFILE_READ), controller.getTel100ModemProfile);
  router.post("/tel100/modem-profile/:id", requirePermission(Permissions.TEL100_MODEM_PROFILE_CREATE), controller.createTel100ModemProfile);
  router.patch("/tel100/modem-profile", requireAuthUser, requirePermission(Permissions.TEL100_MODEM_PROFILE_UPDATE), controller.patchTel100ModemProfile);
  router.get("/tel100/modem-profile/decrypt/:coreDeviceId", requireAuthUser, requirePermission(Permissions.TEL100_MODEM_VIEW), controller.getTel100ModemProfileController);

  return router;
}
