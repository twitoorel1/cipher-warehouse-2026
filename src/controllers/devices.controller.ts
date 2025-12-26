import type { Request, Response, NextFunction } from "express";
import type { Pool } from "mysql2/promise";
import { AppError } from "../middleware/error.middleware.js";
import { devicesListQuerySchema, deviceIdParamSchema } from "../validators/devices.schemas.js";
import { getDeviceCardBySerialService } from "../services/devices/devices.service.js";

export function createDevicesController(pool: Pool) {
  return {
    getBySerial: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const serial = String(req.params.serial ?? "").trim();
        if (!serial) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "serial is required" }));
          return;
        }

        const card = await getDeviceCardBySerialService(pool, serial);
        if (!card) {
          next(new AppError({ code: "NOT_FOUND", status: 404, message: "Device not found" }));
          return;
        }

        res.status(200).json(card);
      } catch (e) {
        next(e);
      }
    },

    // Olders
    // list: async (req: Request, res: Response, next: NextFunction) => {
    //   try {
    //     const parsed = devicesListQuerySchema.safeParse(req.query);
    //     if (!parsed.success) {
    //       next(
    //         new AppError({
    //           code: "VALIDATION_ERROR",
    //           status: 400,
    //           message: "Invalid query parameters",
    //           details: parsed.error.flatten(),
    //         })
    //       );
    //       return;
    //     }
    //     const data = await getDevicesList(pool, parsed.data);
    //     res.status(200).json(data);
    //   } catch (error: any) {
    //     next(error);
    //   }
    // },
    // getById: async (req: Request, res: Response, next: NextFunction) => {
    //   try {
    //     const parsed = deviceIdParamSchema.safeParse(req.params);
    //     if (!parsed.success) {
    //       next(
    //         new AppError({
    //           code: "VALIDATION_ERROR",
    //           status: 400,
    //           message: "Invalid device ID parameter",
    //           details: parsed.error.flatten(),
    //         })
    //       );
    //       return;
    //     }
    //     const devices = await getDeviceDetails(pool, parsed.data.id);
    //     if (!devices) {
    //       next(new AppError({ code: "NOT_FOUND", status: 404, message: "Device not found" }));
    //       return;
    //     }
    //     res.status(200).json({
    //       ...devices,
    //       manual: null,
    //     });
    //   } catch (error: any) {
    //     next(error);
    //   }
    // },
  };
}
