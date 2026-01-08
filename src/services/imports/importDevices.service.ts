import type { Pool } from "mysql2/promise";
import * as XLSXNS from "xlsx";
const XLSX = (XLSXNS as unknown as { default?: typeof XLSXNS }).default ?? XLSXNS;
import { z } from "zod";
import { importInventoryRowSchema, type ImportInventoryRow, storageSiteRegex } from "../../validators/importDevices.schemas.js";
import { deviceTypeByMakat } from "../../config/deviceTypeByMakat.js";
import { getCoreDeviceStateBySerial, insertCoreDevice, updateCoreDeviceInventoryOnly, markRemovedMissingSerials, getOrCreateStorageUnitIdBySite, getEncryptionModelIdByMakat, ImportScope } from "../../db/queries/importDevices.queries.js";
import { AppError } from "../../middleware/error.middleware.js";
import type { ImportDevicesResponse, ImportErrorItem } from "../../types/imports.js";

function extractStorageSite(raw: string): string | null {
  const s = String(raw ?? "").trim();
  if (!s) return null;

  const parts = s.split("/");
  const last = (parts[parts.length - 1] ?? "").trim().toUpperCase();
  if (storageSiteRegex.test(last)) return last;

  const tokenMatch = s.toUpperCase().match(/\b[A-Z]{2,4}\d{2,4}\b/);
  if (tokenMatch?.[0] && storageSiteRegex.test(tokenMatch[0])) return tokenMatch[0];

  return null;
}

function pickExcelFields(obj: Record<string, any>) {
  const get = (...keys: string[]) => keys.map((k) => obj[k]).find((v) => v !== undefined);

  return {
    storageRaw: get("אתר אחסון", "אתר"),
    deviceName: get("תיאור החומר", "תיאור"),
    makat: get("חומר", "מקט"),
    serial: get("מספר סיריאלי", "מספר סידורי", "Serial"),
  };
}

export async function importDevicesInventoryExcel(pool: Pool, filePath: string, scope: ImportScope): Promise<ImportDevicesResponse> {
  const MAX_ROWS = 10_000;
  const MAX_ERRORS = 200;

  const workbook = XLSX.readFile(filePath, { cellDates: false });
  const sheetName = workbook.SheetNames[0];
  if (!sheetName) {
    return {
      processed: 0,
      inserted: 0,
      updated: 0,
      marked_removed: 0,
      failed: 1,
      errors: [
        {
          row_number: 0,
          code: "NO_SHEETS",
          message: "The Excel file does not contain any sheets (SheetNames is empty)",
          fields: { SheetNames: workbook.SheetNames },
        },
      ],
    };
  }

  const sheet = workbook.Sheets[sheetName];
  if (!sheet) {
    throw new AppError({ code: "VALIDATION_ERROR", status: 400, message: "The first sheet in the file is not available for reading." });
  }

  const rawRows = XLSX.utils.sheet_to_json<Record<string, any>>(sheet, { defval: "" });
  if (!Array.isArray(rawRows) || rawRows.length === 0) {
    throw new AppError({ code: "VALIDATION_ERROR", status: 400, message: "The first sheet is empty or not in a supported format." });
  }

  if (rawRows.length > MAX_ROWS) {
    throw new AppError({ code: "VALIDATION_ERROR", status: 400, message: `Too many rows. Max allowed is ${MAX_ROWS}.` });
  }

  let processed = 0;
  let inserted = 0;
  let updated = 0;
  let failed = 0;

  const errors: ImportErrorItem[] = [];
  const presentSerialsSet = new Set<string>();
  const storageSitesSet = new Set<string>();

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    for (let i = 0; i < rawRows.length; i++) {
      const excelRow = rawRows[i] as Record<string, any>;
      const rowNumber = i + 2; // header is row 1

      try {
        const { storageRaw, deviceName, makat, serial } = pickExcelFields(excelRow);

        const storage_unit_raw = String(storageRaw ?? "").trim();
        const extractedSite = extractStorageSite(storage_unit_raw);

        const candidate: Partial<ImportInventoryRow> = {
          serial: String(serial ?? "")
            .trim()
            .toUpperCase(),
          makat: String(makat ?? "").trim(),
          device_name: String(deviceName ?? "").trim(),
          storage_unit_raw,
          storage_site: String(extractedSite ?? "")
            .trim()
            .toUpperCase(),
        };

        const parsed = importInventoryRowSchema.safeParse(candidate);
        if (!parsed.success) {
          failed++;
          if (errors.length < MAX_ERRORS) {
            errors.push({
              row_number: rowNumber,
              code: "ROW_VALIDATION_FAILED",
              message: "Row validation failed",
              fields: parsed.error.flatten(),
            });
          }
          continue;
        }

        const row = parsed.data;

        // de-dupe serials inside file
        if (presentSerialsSet.has(row.serial)) continue;

        processed++;
        presentSerialsSet.add(row.serial);
        storageSitesSet.add(row.storage_site);

        const unitId = await getOrCreateStorageUnitIdBySite(conn, {
          storage_site: row.storage_site,
          unit_name: row.storage_unit_raw,
          scope,
        });

        const encryptionModelId = await getEncryptionModelIdByMakat(conn, row.makat);

        const existing = await getCoreDeviceStateBySerial(conn, row.serial);
        if (!existing) {
          await insertCoreDevice(conn, row, unitId, encryptionModelId);
          inserted++;
        } else {
          const res = await updateCoreDeviceInventoryOnly(conn, row, unitId, encryptionModelId);
          if (res === "updated") updated++;
        }
      } catch (e: any) {
        failed++;
        if (errors.length < MAX_ERRORS) {
          errors.push({
            row_number: rowNumber,
            code: "ROW_FAILED",
            message: e?.message ? String(e.message) : "Unknown error",
            fields: { excelRow },
          });
        }
        continue;
      }
    }

    const presentSerials = Array.from(presentSerialsSet);
    const storageSites = Array.from(storageSitesSet);

    const marked_removed = await markRemovedMissingSerials(conn, { presentSerials, storageSites, scope });

    await conn.commit();

    return { processed, inserted, updated, marked_removed, failed, errors };
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }
}
