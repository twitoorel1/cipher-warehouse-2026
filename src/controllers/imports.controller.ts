import type { Request, Response, NextFunction } from "express";
import type { Pool } from "mysql2/promise";
import { AppError } from "@middleware/error.middleware.js";
import { importDevicesInventoryExcel } from "@services/imports/importDevices.service.js";
import fs from "node:fs/promises";
import path from "node:path";

type MulterFile = Express.Multer.File;

export function createImportsController(pool: Pool) {
  return {
    importDevices: async (req: Request, res: Response, next: NextFunction) => {
      const file = req.file as MulterFile | undefined;

      try {
        if (!file?.path) {
          next(new AppError({ code: "NO_FILE", status: 400, message: "File is required" }));
          return;
        }

        const user = req.user as { battalion_id?: number | null; division_id?: number | null } | undefined;
        const scope = {
          battalion_id: user?.battalion_id ?? null,
          division_id: user?.division_id ?? null,
        };

        const result = await importDevicesInventoryExcel(pool, file.path, scope);
        res.status(201).json(result);
      } catch (e) {
        next(e);
      } finally {
        if (file?.path) {
          try {
            await fs.unlink(file.path);
          } catch {
            // ignore
          }
        }
      }
    },
  };
}
