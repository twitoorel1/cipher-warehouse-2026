import type { Pool } from "mysql2/promise";
import * as XLSXNS from "xlsx";
const XLSX: typeof XLSXNS = (XLSXNS as any).default ?? XLSXNS;

import { importInventoryRowSchema, type ImportInventoryRow, storageSiteRegex } from "../../validators/importDevices.schemas.js";
import {
  getCoreDeviceStateBySerial,
  insertCoreDevice,
  updateCoreDeviceInventoryOnly,
  updateCoreDeviceInventoryOnlyScoped,
  markRemovedMissingSerials,
  getOrCreateStorageUnitIdBySite,
  getEncryptionModelIdByMakat,
  type ImportScope,
} from "../../db/queries/importDevices.queries.js";

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

function normHeader(v: any) {
  return String(v ?? "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, " ");
}

// Supports merged headers: when a merged header spans multiple columns,
// Excel often leaves subsequent header cells blank.
// forwardFill assigns the last non-empty header to empty cells.
function forwardFillHeaders(headers: any[]): string[] {
  const out: string[] = [];
  let last = "";
  for (const h of headers) {
    const n = normHeader(h);
    if (n) last = n;
    out.push(last);
  }
  return out;
}

function findHeaderIndices(ffHeaders: string[], wanted: string): number[] {
  const w = normHeader(wanted);
  const idx: number[] = [];
  for (let i = 0; i < ffHeaders.length; i++) {
    if (ffHeaders[i] === w) idx.push(i);
  }
  return idx;
}

function getCell(row: any[], idx: number) {
  if (!row) return "";
  if (idx < 0 || idx >= row.length) return "";
  return row[idx];
}

function s(v: any) {
  return String(v ?? "").trim();
}

function u(v: any) {
  return s(v).toUpperCase();
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

  // Read as matrix to avoid problems with duplicated / merged headers
  const matrix = XLSX.utils.sheet_to_json<any[]>(sheet, { header: 1, defval: "" }) as any[][];
  if (!Array.isArray(matrix) || matrix.length <= 1) {
    throw new AppError({ code: "VALIDATION_ERROR", status: 400, message: "The first sheet is empty or not in a supported format." });
  }

  const headersRow = (matrix[0] ?? []) as any[];
  const dataRows = matrix.slice(1);

  if (dataRows.length > MAX_ROWS) {
    throw new AppError({ code: "VALIDATION_ERROR", status: 400, message: `Too many rows. Max allowed is ${MAX_ROWS}.` });
  }

  const ffHeaders = forwardFillHeaders(headersRow);

  // We expect merged pairs:
  // - "אתר אחסון" => 2 columns (code + name)
  // - "חומר" => 2 columns (makat + device_name)
  // - "צ'" => 1 column (serial)
  const storageIdx = findHeaderIndices(ffHeaders, "אתר אחסון");
  const materialIdx = findHeaderIndices(ffHeaders, "חומר");
  const serialIdxList = findHeaderIndices(ffHeaders, "צ'");

  if (storageIdx.length < 2) {
    throw new AppError({
      code: "VALIDATION_ERROR",
      status: 400,
      message: 'Excel headers are missing a merged pair for "אתר אחסון" (expected 2 columns).',
    });
  }
  if (materialIdx.length < 2) {
    throw new AppError({
      code: "VALIDATION_ERROR",
      status: 400,
      message: 'Excel headers are missing a merged pair for "חומר" (expected 2 columns).',
    });
  }
  if (serialIdxList.length < 1) {
    throw new AppError({
      code: "VALIDATION_ERROR",
      status: 400,
      message: 'Excel headers are missing column "צ\'" (serial).',
    });
  }

  // Fix TypeScript: after guardrails, assert as non-null numbers
  const storageCodeIdx: number = storageIdx[0]!;
  const storageNameIdx: number = storageIdx[1]!;
  const makatIdx: number = materialIdx[0]!;
  const deviceNameIdx: number = materialIdx[1]!;
  const serialIdx: number = serialIdxList[0]!;

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

    for (let i = 0; i < dataRows.length; i++) {
      const rowArr = dataRows[i] as any[];
      const rowNumber = i + 2; // headers are row 1

      try {
        const storageSiteCode = u(getCell(rowArr, storageCodeIdx)); // MG01
        const storageUnitName = s(getCell(rowArr, storageNameIdx)); // name/description
        const makat = s(getCell(rowArr, makatIdx)); // makat (J)
        const deviceName = s(getCell(rowArr, deviceNameIdx)); // device_name (K)
        const serial = u(getCell(rowArr, serialIdx)); // serial (צ')

        // Minimal safe fallbacks (do not guess other unrelated columns)
        const storage_site_raw = storageSiteCode || u(extractStorageSite(storageUnitName) ?? "");
        const storage_unit_raw = storageUnitName || storage_site_raw;

        const candidate: Partial<ImportInventoryRow> = {
          serial,
          makat,
          device_name: deviceName,
          storage_unit_raw,
          storage_site: storage_site_raw, // use code column directly (best)
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

        // de-dupe serials inside the file
        if (presentSerialsSet.has(row.serial)) continue;

        processed++;
        presentSerialsSet.add(row.serial);
        storageSitesSet.add(row.storage_site);

        // Keep existing behavior: create storage unit if missing, update name if exists
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
          // const res = await updateCoreDeviceInventoryOnly(conn, row, unitId, encryptionModelId);
          // if (res === "updated") updated++;
          const res = await updateCoreDeviceInventoryOnlyScoped(conn, row, unitId, encryptionModelId, scope);
          if (res === "updated") {
            updated++;
          } else if (res === "forbidden") {
            failed++;
            if (errors.length < MAX_ERRORS) {
              errors.push({
                row_number: rowNumber,
                code: "OUT_OF_SCOPE",
                message: "Device exists but is out of your scope (serial update blocked)",
                fields: { serial: row.serial },
              });
            }
          }
        }
      } catch (e: any) {
        failed++;
        if (errors.length < MAX_ERRORS) {
          errors.push({
            row_number: rowNumber,
            code: "ROW_FAILED",
            message: e?.message ? String(e.message) : "Unknown error",
            fields: { row: rowArr },
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
