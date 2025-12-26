import type { Pool, RowDataPacket, ResultSetHeader } from "mysql2/promise";
import type { ImportInventoryRow } from "../../validators/importDevices.schemas.js";
import { DeviceTypeCode } from "../../types/imports.js";

export async function getOrCreateStorageUnitIdBySite(pool: Pool, input: { storage_site: string; unit_name: string }): Promise<number> {
  const storageSite = String(input.storage_site).trim().toUpperCase();
  const unitName = String(input.unit_name).trim();

  if (!storageSite) throw new Error("getOrCreateStorageUnitIdBySite: storage_site is empty");
  if (!unitName) throw new Error("getOrCreateStorageUnitIdBySite: unit_name is empty");

  const [rows] = await pool.query<(RowDataPacket & { id: number; unit_name: string })[]>(
    `
    SELECT id, unit_name
    FROM storage_units
    WHERE storage_site = ? AND is_active = 1
    LIMIT 1
    `,
    [storageSite]
  );

  if (rows.length > 0) {
    const existing = rows[0] as RowDataPacket & { id: number; unit_name: string };

    // Keep name synced (optional, but useful)
    if (existing.unit_name !== unitName) {
      await pool.query<ResultSetHeader>(
        `
        UPDATE storage_units
        SET unit_name = ?
        WHERE id = ?
        `,
        [unitName, existing.id]
      );
    }

    return Number(existing.id);
  }

  const [ins] = await pool.query<ResultSetHeader>(
    `
    INSERT INTO storage_units (unit_name, storage_site, is_active)
    VALUES (?, ?, 1)
    `,
    [unitName, storageSite]
  );

  return Number(ins.insertId);
}

/**
 * Minimal state fetch by serial (for "insert vs update" decision).
 */
export async function getCoreDeviceStateBySerial(pool: Pool, serial: string): Promise<{ id: number; lifecycle_status: string; current_unit_id: number | null } | null> {
  const s = String(serial).trim();
  if (!s) throw new Error("getCoreDeviceStateBySerial: serial is empty");

  const [rows] = await pool.query<(RowDataPacket & { id: number; lifecycle_status: string; current_unit_id: number | null })[]>(
    `
    SELECT id, lifecycle_status, current_unit_id
    FROM core_device
    WHERE serial = ? AND deleted_at IS NULL
    LIMIT 1
    `,
    [s]
  );

  const first = rows[0];
  if (!first) return null;

  return {
    id: Number(first.id),
    lifecycle_status: String(first.lifecycle_status),
    current_unit_id: first.current_unit_id === null ? null : Number(first.current_unit_id),
  };
}

/**
 * OPTIONAL (recommended):
 * link makat -> encryption_device_model.id (if table is populated).
 * If not found, returns null (system still works).
 */
export async function getEncryptionModelIdByMakat(pool: Pool, makat: string): Promise<number | null> {
  const m = String(makat).trim();
  if (!m) return null;

  const [rows] = await pool.query<(RowDataPacket & { id: number })[]>(
    `
    SELECT id
    FROM encryption_device_model
    WHERE makat = ? AND is_active = 1
    LIMIT 1
    `,
    [m]
  );

  const first = rows[0];
  if (!first) return null;

  return Number(first.id);
  // return rows.length ? Number(rows[0].id) : null;
}

/**
 * Insert a new device card.
 * - current_unit_id is a FK to storage_units
 * - encryption_model_id is optional (nullable)
 * - lifecycle_status starts as NEW
 */
export async function insertCoreDevice(pool: Pool, row: ImportInventoryRow, unitId: number, encryptionModelId: number | null): Promise<void> {
  await pool.query<ResultSetHeader>(
    `
    INSERT INTO core_device
      (serial, makat, device_name, current_unit_id, encryption_model_id, lifecycle_status)
    VALUES
      (?, ?, ?, ?, ?, 'NEW')
    `,
    [row.serial, row.makat, row.device_name, unitId, encryptionModelId]
  );
}

/**
 * Update inventory-only fields from Excel.
 * Also "revives" REMOVED -> ACTIVE when a device reappears.
 *
 * Returns:
 * - "updated"   if a row matched the serial (and update statement executed)
 * - "unchanged" if no row matched (serial not found or deleted_at not null)
 */
export async function updateCoreDeviceInventoryOnly(pool: Pool, row: ImportInventoryRow, unitId: number, encryptionModelId: number | null): Promise<"updated" | "unchanged"> {
  const [res] = await pool.query<ResultSetHeader>(
    `
    UPDATE core_device
    SET
      makat = ?,
      device_name = ?,
      current_unit_id = ?,
      encryption_model_id = COALESCE(?, encryption_model_id),
      lifecycle_status = CASE
        WHEN lifecycle_status = 'REMOVED' THEN 'ACTIVE'
        ELSE lifecycle_status
      END
    WHERE serial = ? AND deleted_at IS NULL
    `,
    [row.makat, row.device_name, unitId, encryptionModelId, row.serial]
  );

  return res.affectedRows > 0 ? "updated" : "unchanged";
}

/**
 * Marks devices as REMOVED if they are not present in the current Excel import.
 * presentSerials = all serials seen in the file for YOUR scope (your units).
 *
 * Implementation:
 * - Select all serials from core_device (not deleted)
 * - Compute the missing ones in memory
 * - Update in chunks using IN (...)
 */
export async function markRemovedMissingSerials(pool: Pool, presentSerials: string[]): Promise<number> {
  if (presentSerials.length === 0) return 0;

  const CHUNK = 800;

  const present = new Set(presentSerials.map((s) => String(s).trim()).filter(Boolean));

  const [serialRows] = await pool.query<(RowDataPacket & { serial: string })[]>(
    `
    SELECT serial
    FROM core_device
    WHERE deleted_at IS NULL AND serial IS NOT NULL
    `
  );

  const toRemove: string[] = [];
  for (const r of serialRows) {
    const s = String(r.serial ?? "").trim();
    if (!s) continue;
    if (!present.has(s)) toRemove.push(s);
  }

  if (toRemove.length === 0) return 0;

  let totalMarked = 0;

  for (let i = 0; i < toRemove.length; i += CHUNK) {
    const part = toRemove.slice(i, i + CHUNK);
    const [res] = await pool.query<ResultSetHeader>(
      `
      UPDATE core_device
      SET lifecycle_status = 'REMOVED'
      WHERE deleted_at IS NULL
        AND serial IN (${part.map(() => "?").join(",")})
        AND lifecycle_status <> 'REMOVED'
      `,
      part
    );
    totalMarked += Number(res.affectedRows ?? 0);
  }

  return totalMarked;
}
