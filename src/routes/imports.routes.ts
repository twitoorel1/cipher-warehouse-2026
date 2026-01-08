import { Router, Request } from "express";
import multer from "multer";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "@/config/env.js";
import { requireAdmin } from "@middleware/rbac.middleware.js";
import { createImportsController } from "@controllers/imports.controller.js";
import { requirePermission } from "@/middleware/requirePermission.middleware.js";
import { Permissions } from "@/types/permissions.js";
import { AppError } from "@/middleware/error.middleware.js";

import { promises as fs } from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

// מביא את הנתיב של התיקייה
const UPLOAD_DIR = path.resolve(process.cwd(), "tmp", "uploads");
const MAX_UPLOAD_BYTES = 10 * 1024 * 1024; // 10MB

// מבטיח שהתיקייה קיימת (אם לא, יוצר אותה)
async function ensureUploadDir(): Promise<void> {
  await fs.mkdir(UPLOAD_DIR, { recursive: true });
}

function safeExt(originalName: string): string {
  return path.extname(originalName).toLowerCase();
}

function isAllowedExcel(file: Express.Multer.File): boolean {
  const ext = safeExt(file.originalname);
  if (ext !== ".xlsx") return false;

  const allowedMime = new Set(["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/octet-stream"]);
  return allowedMime.has(file.mimetype);
}

function makeFilename(originalName: string): string {
  const ext = safeExt(originalName) || ".xlsx";
  return `${Date.now()}-${crypto.randomBytes(8).toString("hex")}${ext}`;
}

// מוחק קובץ בצורה בטוחה (אם קיים)
async function safeUnlink(filePath: string) {
  try {
    await fs.unlink(filePath);
  } catch {
    return;
  }
}

const storage = multer.diskStorage({
  destination: async (_req: Request, _file, cb) => {
    try {
      await ensureUploadDir();
      cb(null, UPLOAD_DIR);
    } catch (e) {
      cb(e as Error, UPLOAD_DIR);
    }
  },
  filename: (_req: Request, file, cb) => {
    const ext = safeExt(file.originalname) || ".xlsx";
    const name = `${Date.now()}-${crypto.randomBytes(8).toString("hex")}${ext}`;
    cb(null, name);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: MAX_UPLOAD_BYTES, files: 1 },
  fileFilter: (_req, file, cb) => {
    if (!isAllowedExcel(file)) {
      cb(new AppError({ code: "INVALID_FILE", status: 400, message: "Only .xlsx files are allowed" }));
      return;
    }
    cb(null, true);
  },
});

export function createImportsRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const controller = createImportsController(pool);

  router.post("/devices", requirePermission(Permissions.DEVICES_IMPORT), requireAdmin(), upload.single("file"), controller.importDevices);

  return router;
}
