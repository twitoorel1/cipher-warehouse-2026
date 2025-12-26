import type { Request, Response, NextFunction } from "express";
import type { Pool } from "mysql2/promise";
import { AppError } from "../middleware/error.middleware.js";
import { importDevicesInventoryExcel } from "../services/imports/importDevices.service.js";
import fs from "node:fs/promises";

type MulterFile = Express.Multer.File;

export function createImportsController(pool: Pool) {
  return {
    importDevices: async (req: Request, res: Response, next: NextFunction) => {
      // const file = (req as any).file as { path?: string } | undefined;
      const file = req.file as MulterFile | undefined;

      try {
        if (!file?.path) {
          next(new AppError({ code: "VALIDATION_ERROR", status: 400, message: "Missing file. Expected multipart/form-data field named 'file'." }));
          return;
        }

        const result = await importDevicesInventoryExcel(pool, file.path);
        res.status(201).json(result);
      } catch (e) {
        next(e);
      } finally {
        if (file?.path) {
          try {
            await fs.unlink(file.path);
          } catch {}
        }
      }
    },
  };
}
