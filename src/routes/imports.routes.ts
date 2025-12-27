import { Router, Request } from "express";
import multer from "multer";
import type { Pool } from "mysql2/promise";
import type { AppEnv } from "../config/env.js";
import { createAuthMiddleware } from "../middleware/auth.middleware.js";
import { requireAdmin } from "../middleware/rbac.middleware.js";
import { createImportsController } from "../controllers/imports.controller.js";
import { promises as fs } from "node:fs";
import path from "node:path";
import { Roles } from "../types/auth.js";

// מביא את הנתיב של התיקייה
const UPLOAD_DIR = path.resolve(process.cwd(), "tmp", "uploads");

// מבטיח שהתיקייה קיימת (אם לא, יוצר אותה)
async function ensureUploadDir(): Promise<void> {
  await fs.mkdir(UPLOAD_DIR, { recursive: true });
}

function safeExt(originalName: string): string {
  const ext = path.extname(originalName || "").toLowerCase();
  // allow common excel types
  if (ext === ".xlsx" || ext === ".xls" || ext === ".csv") return ext;
  // default to xlsx if unknown
  return ".xlsx";
}

function makeFilename(originalName: string): string {
  const id = crypto.randomUUID();
  return `import_${Date.now()}_${id}${safeExt(originalName)}`;
}

// מוחק קובץ בצורה בטוחה (אם קיים)
async function safeUnlink(filePath: string) {
  try {
    await fs.unlink(filePath);
  } catch {
    return;
  }
}

export function createImportsRouter(pool: Pool, env: AppEnv) {
  const router = Router();
  const auth = createAuthMiddleware(env);
  const controller = createImportsController(pool);

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
      cb(null, makeFilename(file.originalname));
    },
  });

  const upload = multer({
    storage,
    limits: { fileSize: 20 * 1024 * 1024, files: 1 }, // 20 MB
  });

  router.post("/devices", auth, requireAdmin(), upload.single("file"), controller.importDevices);

  // router.post("/imports/devices", auth, requireRole(Roles.ADMIN), upload.single("file"), async (req, res, next) => {
  //   const file = (req as any).file as { path?: string } | undefined;
  //   try {
  //     await controller.importDevices(req, res, next);
  //   } finally {
  //     if (file?.path) await safeUnlink(file.path);
  //   }
  // });

  return router;
}
