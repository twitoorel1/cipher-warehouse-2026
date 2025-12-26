import type { Pool } from "mysql2/promise";
import * as XLSXNS from "xlsx";
const XLSX = (XLSXNS as unknown as { default?: typeof XLSXNS }).default ?? XLSXNS;
import { z } from "zod";
import { importInventoryRowSchema, type ImportInventoryRow, storageSiteRegex } from "../../validators/importDevices.schemas.js";
import { deviceTypeByMakat } from "../../config/deviceTypeByMakat.js";
import { getCoreDeviceStateBySerial, insertCoreDevice, updateCoreDeviceInventoryOnly, markRemovedMissingSerials, getOrCreateStorageUnitIdBySite, getEncryptionModelIdByMakat } from "../../db/queries/importDevices.queries.js";
import { AppError } from "../../middleware/error.middleware.js";
import type { ImportDevicesResponse, ImportErrorItem } from "../../types/imports.js";

function extractStorageSite(raw: string): string | null {
  const s = String(raw ?? "").trim();
  if (!s) return null;

  // 1) Prefer last segment after '/'
  const parts = s.split("/");
  const last = (parts[parts.length - 1] ?? "").trim().toUpperCase();
  if (storageSiteRegex.test(last)) return last;

  // 2) Fallback: token search anywhere
  const tokenMatch = s.toUpperCase().match(/\b[A-Z]{2,4}\d{2,4}\b/);
  if (tokenMatch?.[0] && storageSiteRegex.test(tokenMatch[0])) return tokenMatch[0];

  return null;
}

function pickExcelFields(obj: Record<string, any>) {
  return {
    storageRaw: obj["אתר אחסון"],
    deviceName: obj["תיאור החומר"],
    makat: obj["חומר"],
    serial: obj["מספר סיריאלי"],
  };
}

export async function importDevicesInventoryExcel(pool: Pool, filePath: string): Promise<ImportDevicesResponse> {
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
      // errors: [{ row: 0, message: "Excel has no sheets" }],
    };
  }

  const sheet = workbook.Sheets[sheetName];
  if (!sheet) {
    throw new AppError({
      code: "VALIDATION_ERROR",
      status: 400,
      message: "The first sheet in the file is not available for reading.",
    });
  }

  const rawRows = XLSX.utils.sheet_to_json<Record<string, any>>(sheet, { defval: "" });
  if (!Array.isArray(rawRows) || rawRows.length === 0) {
    throw new AppError({
      code: "VALIDATION_ERROR",
      status: 400,
      message: "The first sheet is empty or not in a supported format.",
    });
  }

  let processed = 0;
  let inserted = 0;
  let updated = 0;
  let failed = 0;

  const errors: ImportErrorItem[] = [];
  const presentSerials: string[] = [];

  for (let i = 0; i < rawRows.length; i++) {
    const excelRow = rawRows[i] as Record<string, any>;
    const rowNumber = i + 2; // header row is 1

    try {
      const { storageRaw, deviceName, makat, serial } = pickExcelFields(excelRow);

      const storage_unit_raw = String(storageRaw ?? "").trim();
      const extractedSite = extractStorageSite(storage_unit_raw);

      const candidate: Partial<ImportInventoryRow> = {
        serial: String(serial ?? "").trim(),
        makat: String(makat ?? "").trim(),
        device_name: String(deviceName ?? "").trim(),
        storage_unit_raw,
        storage_site: extractedSite ?? "",
      };

      const parsed = importInventoryRowSchema.safeParse(candidate);
      if (!parsed.success) {
        failed++;
        errors.push({
          row_number: rowNumber,
          code: "ROW_VALIDATION_FAILED",
          message: "Row validation failed",
          fields: parsed.error.flatten(),
        });
        continue;
      }

      const row = parsed.data;

      processed++;
      presentSerials.push(row.serial);

      // Ensure unit exists (storage_units) and get its ID
      const unitId = await getOrCreateStorageUnitIdBySite(pool, {
        storage_site: row.storage_site,
        unit_name: row.storage_unit_raw,
      });

      // OPTIONAL: link to encryption model by makat (if table getEncryptionModelIdByMakat populated)
      const encryptionModelId = await getEncryptionModelIdByMakat(pool, row.makat);

      // Insert or update core_device
      const existing = await getCoreDeviceStateBySerial(pool, row.serial);
      if (!existing) {
        await insertCoreDevice(pool, row, unitId, encryptionModelId);
        inserted++;
      } else {
        const res = await updateCoreDeviceInventoryOnly(pool, row, unitId, encryptionModelId);
        if (res === "updated") updated++;
      }
    } catch (e: any) {
      failed++;
      errors.push({
        row_number: rowNumber,
        code: "ROW_VALIDATION_FAILED",
        message: e?.message ? String(e.message) : "Unknown error",
        fields: { excelRow },
      });
      continue;
    }
  }

  const marked_removed = await markRemovedMissingSerials(pool, presentSerials);

  return {
    processed,
    inserted,
    updated,
    marked_removed,
    failed,
    errors,
  };
}
