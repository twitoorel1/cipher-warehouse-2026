import type { Request, Response, NextFunction } from "express";
import type { Pool } from "mysql2/promise";
import { AppError } from "@middleware/error.middleware.js";
import { devicesListQuerySchema, deviceIdParamSchema, devicePatchSchema } from "@validators/devices.schemas.js";
import { AuthUser } from "@/types/auth.js";
import { getDevicesList, getDeviceCardBySerialService, getDeviceDetails, updateDeviceByIdService, getTel100DevicesList } from "@services/devices/devices.service.js";
import { createTel100ModemProfile, createTel100VoiceProfile, getTel100ModemProfile, getTel100VoiceProfile } from "@/db/queries/tel100Profiles.queries.js";
import { getTel100ModemProfileService, updateTel100ModemProfileService, updateTel100VoiceProfileService } from "@/services/tel100/tel100Profiles.service.js";
import z from "zod";
import { modemPatchSchema, tel100VoiceProfileUpsertSchema } from "@/validators/tel100Profiles.schemas.js";
import { decryptUtf8, EncryptedBundle } from "@/crypto/fieldCrypto.js";
import { can } from "@/rbac/can.js";
import { Permissions } from "@/types/permissions.js";

export function createDevicesController(pool: Pool) {
  return {
    getBySerial: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const serial = String(req.params.serial ?? "").trim();
        if (!serial) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "serial is required" }));
          return;
        }

        const user = (req as any).user as AuthUser;
        const card = await getDeviceCardBySerialService(pool, serial, user);
        if (!card) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "Device not found" }));
          return;
        }

        res.status(200).json(card.device);
      } catch (e) {
        return next(e);
      }
    },

    getById: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = deviceIdParamSchema.safeParse(req.params);
        if (!parsed.success) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid device ID parameter",
              details: parsed.error.flatten(),
            })
          );
          return;
        }

        const user = (req as any).user as AuthUser;
        const devices = await getDeviceDetails(pool, parsed.data.id, user);
        if (!devices) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "Devices not found" }));
          return;
        }
        res.status(200).json({
          ...devices.device,
          manual: null,
        });
      } catch (e) {
        return next(e);
      }
    },

    list: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = devicesListQuerySchema.safeParse(req.query);
        if (!parsed.success) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid query parameters",
              details: parsed.error.flatten(),
            })
          );
          return;
        }

        const user = (req as any).user as AuthUser;
        const data = await getDevicesList(pool, parsed.data, user);
        res.status(200).json(data);
      } catch (e) {
        return next(e);
      }
    },

    updateById: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsedParams = deviceIdParamSchema.safeParse(req.params);
        if (!parsedParams.success) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid device ID parameter",
              details: parsedParams.error.flatten(),
            })
          );
          return;
        }

        if (req.body && ("serial" in req.body || "current_unit_id" in req.body)) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "serial/current_unit_id cannot be updated via this endpoint",
            })
          );
          return;
        }

        const parsedBody = devicePatchSchema.safeParse(req.body ?? {});
        if (!parsedBody.success) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid request body",
              details: parsedBody.error.flatten(),
            })
          );
          return;
        }

        const user = (req as any).user as AuthUser;
        const updated = await updateDeviceByIdService(pool, parsedParams.data.id, parsedBody.data, user);
        if (!updated) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "Device not found" }));
          return;
        }

        res.status(200).json({ ...updated.device, manual: null });
      } catch (e) {
        return next(e);
      }
    },

    getTel100Devices: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = devicesListQuerySchema.safeParse(req.query);
        if (!parsed.success) {
          next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid query parameters",
              details: parsed.error.flatten(),
            })
          );
          return;
        }

        const user = (req as any).user as AuthUser;
        const data = await getTel100DevicesList(pool, parsed.data, user);
        res.status(200).json(data);
      } catch (e) {
        return next(e);
      }
    },

    getTel100VoiceProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = deviceIdParamSchema.safeParse(req.params);
        if (!parsed.success) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid id", details: parsed.error.flatten() }));
          return;
        }

        const user = (req as any).user as AuthUser;
        const row = await getTel100VoiceProfile(pool, { coreDeviceId: parsed.data.id, user });

        if (!row) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "TEL100 voice profile not found" }));
          return;
        }

        res.status(200).json(row);
      } catch (e) {
        return next(e);
      }
    },

    getTel100ModemProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = deviceIdParamSchema.safeParse(req.params);
        if (!parsed.success) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid id", details: parsed.error.flatten() }));
          return;
        }

        const user = (req as any).user as AuthUser;
        const row = await getTel100ModemProfile(pool, { coreDeviceId: parsed.data.id, user });

        if (!row) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "TEL100 modem profile not found" }));
          return;
        }

        res.status(200).json(row);
      } catch (e) {
        return next(e);
      }
    },

    createTel100VoiceProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = deviceIdParamSchema.safeParse(req.params);
        if (!parsed.success) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid device ID parameter", details: parsed.error.flatten() }));
          return;
        }

        const user = (req as any).user as AuthUser;

        const r = await createTel100VoiceProfile(pool, { coreDeviceId: parsed.data.id, user });
        if (!r.created) {
          next(new AppError({ code: "FORBIDDEN", status: 403, message: "Not allowed or device not found" }));
          return;
        }

        res.status(201).json({ ok: true });
      } catch (e: any) {
        // duplicate key -> profile already exists
        if (e?.code === "ER_DUP_ENTRY") {
          next(new AppError({ code: "CONFLICT", status: 409, message: "TEL100 voice profile already exists" }));
          return;
        }
        return next(e);
      }
    },

    createTel100ModemProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const parsed = deviceIdParamSchema.safeParse(req.params);
        if (!parsed.success) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid device ID parameter", details: parsed.error.flatten() }));
          return;
        }

        const user = (req as any).user as AuthUser;

        const r = await createTel100ModemProfile(pool, { coreDeviceId: parsed.data.id, user });
        if (!r.created) {
          next(new AppError({ code: "FORBIDDEN", status: 403, message: "Not allowed or device not found" }));
          return;
        }

        res.status(201).json({ ok: true });
      } catch (e: any) {
        if (e?.code === "ER_DUP_ENTRY") {
          next(new AppError({ code: "CONFLICT", status: 409, message: "TEL100 modem profile already exists" }));
          return;
        }
        return next(e);
      }
    },

    patchTel100ModemProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const user = req.user as AuthUser;
        const keyring = req.keyring as AuthUser["keyring"];

        if (!user) return next(new Error("Unauthorized (req.user missing)"));
        if (!keyring) return next(new Error("Keyring missing on request"));

        const parsed = modemPatchSchema.safeParse(req.body ?? {});
        if (!parsed.success) {
          return next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid request body",
              details: parsed.error.flatten(),
            })
          );
        }
        const body = parsed.data as any;

        await updateTel100ModemProfileService(pool, keyring, user, body);
        return res.status(204).send("Updated successfully");
      } catch (err) {
        return next(err);
      }
    },

    // not encrypted view
    async getTel100ModemProfileController(req: Request, res: Response, next: NextFunction) {
      try {
        const coreDeviceId = Number(req.params.coreDeviceId);
        if (!Number.isFinite(coreDeviceId) || coreDeviceId <= 0) {
          return next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid coreDeviceId",
            })
          );
        }

        const user = req.user as AuthUser;
        const keyring = req.keyring as AuthUser["keyring"];

        if (!user) return next(new Error("Unauthorized (req.user missing)"));
        if (!keyring) return next(new Error("Keyring missing on request"));

        const result = await getTel100ModemProfileService(pool, keyring, user, coreDeviceId);
        res.status(200).json(result);
      } catch (err) {
        next(err);
      }
    },

    // not encrypted view
    getTel100VoiceProfileController: async (req: Request, res: Response, next: NextFunction) => {
      try {
        // const parsed = deviceIdParamSchema.safeParse(req.params.coreDeviceId);
        // if (!parsed.success) {
        //   next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid id", details: parsed.error.flatten() }));
        //   return;
        // }
        const coreDeviceId = Number(req.params.coreDeviceId);
        if (!Number.isFinite(coreDeviceId) || coreDeviceId <= 0) {
          return next(
            new AppError({
              code: "VALIDATION_ERROR",
              status: 400,
              message: "Invalid coreDeviceId",
            })
          );
        }

        const user = (req as any).user as AuthUser;
        const keyring = (req as any).keyring; // req.keyring
        if (!user) return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
        if (!keyring) return next(new Error("Keyring missing on request"));

        const row = await getTel100VoiceProfile(pool, { coreDeviceId, user });
        if (!row) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "TEL100 voice profile not found" }));
          return;
        }

        const allowSensitive = can(user as any, Permissions.TEL100_VOICE_VIEW_PLAINTEXT, { silent: true });
        const aadBase = `tel100_voice_profile:${row.core_device_id}`;

        const dec = (base: string) => {
          if (!allowSensitive) return null; // לא חושפים בלי הרשאה
          const b = bundleFromRow(row, base);
          if (!b) return null;
          return decryptUtf8(keyring, b, `${aadBase}:${base}`);
        };

        res.status(200).json({
          core_device_id: row.core_device_id,
          serial: row.serial,
          device_name: row.device_name,
          makat: row.makat,
          current_unit: {
            id: row.current_unit_id,
            unit_name: row.current_unit_name,
            storage_site: row.current_storage_site,
          },
          full_name: row.full_name,
          user_type: row.user_type,
          personal_number: row.personal_number,
          job_title: row.job_title,
          phone_number: row.phone_number,
          ptt_status: row.ptt_status,

          // plaintext מפוענח (או null אם אין הרשאה)
          ptt_group: dec("ptt_group"),
          hub_password: dec("hub_password"),
          operational_auth_code: dec("operational_auth_code"),
          device_pin: dec("device_pin"),
          opening_template: dec("opening_template"),
          sim_black: dec("sim_black"),
          sim_red_binding_id: dec("sim_red_binding_id"),
          sim_red_copy_marking_short: dec("sim_red_copy_marking_short"),
          sim_red_copy_marking_long: dec("sim_red_copy_marking_long"),

          created_at: row.created_at,
          updated_at: row.updated_at,
        });
      } catch (e) {
        return next(e);
      }
    },

    patchTel100VoiceProfile: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const user = (req as any).user as AuthUser;
        const keyring = (req as any).keyring;
        if (!user) return next(new AppError({ code: "UNAUTHORIZED", status: 401, message: "Unauthorized" }));
        if (!keyring) return next(new Error("Keyring missing on request"));

        // אם אתה שולח coreDeviceId בגוף (כמו שעשית במודם) — זה normalization:
        const parsedBody = tel100VoiceProfileUpsertSchema
          .omit({ core_device_id: true })
          .extend({ coreDeviceId: tel100VoiceProfileUpsertSchema.shape.core_device_id })
          .safeParse(req.body ?? {});

        if (!parsedBody.success) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Invalid request body", details: parsedBody.error.flatten() }));
          return;
        }

        // Filter out undefined values to match the service function's expected type
        const cleanedData = Object.fromEntries(Object.entries(parsedBody.data).filter(([_, value]) => value !== undefined)) as typeof parsedBody.data & { [K in keyof typeof parsedBody.data]: Exclude<(typeof parsedBody.data)[K], undefined> };

        await updateTel100VoiceProfileService(pool, keyring, user, cleanedData);
        res.status(204).send();
      } catch (e) {
        return next(e);
      }
    },
  };
}
function bundleFromRow(row: any, base: string): EncryptedBundle | null {
  const ct = row[`${base}_ct`];
  const iv = row[`${base}_iv`];
  const tag = row[`${base}_tag`];
  const kv = row[`${base}_kv`];

  if (ct == null && iv == null && tag == null && kv == null) return null;
  if (ct == null || iv == null || tag == null || kv == null) return null;

  return { ct, iv, tag, kv: Number(kv) };
}
