import type { Request, Response, NextFunction } from "express";
import type { Pool } from "mysql2/promise";
import { AppError } from "../middleware/error.middleware.js";
import { devicesListQuerySchema, deviceIdParamSchema } from "../validators/devices.schemas.js";
import { getDeviceCardBySerialService, getDeviceDetails, getDevicesList } from "../services/devices/devices.service.js";

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

        const devices = await getDeviceDetails(pool, parsed.data.id);
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

        const data = await getDevicesList(pool, parsed.data);
        res.status(200).json(data);
      } catch (e) {
        return next(e);
      }
    },

    // getByBatteryLife: async (req: Request, res: Response, next: NextFunction) => {
    //   try {
    //     const batteryLife = `${momentTimezone().year()}-${String(req.query.battery_life).trim()}-01`;
    //     if (!batteryLife) {
    //       next(
    //         new AppError({
    //           code: "VALIDATION_ERROR",
    //           status: 400,
    //           message: "battery_life is required",
    //         })
    //       );
    //       return;
    //     }

    //     const data = await getDeviceByBatteryLife(pool, batteryLife);
    //     res.status(200).json(data);
    //   } catch (e) {
    //     return next(e);
    //   }
    // },

    // updateById: async (req: Request, res: Response, next: NextFunction) => {
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

    //     console.log(parsed.data.id);
    //     const device = await updateDeviceById(pool, parsed.data.id);
    //     if (!device) {
    //       next(new AppError({ code: "NOT_FOUND", status: 404, message: "Devices not found" }));
    //       return;
    //     }
    //     res.status(200).json({
    //       mss: "ok",
    //     });
    //   } catch (e) {
    //     return next(e);
    //   }
    // },
  };
}
