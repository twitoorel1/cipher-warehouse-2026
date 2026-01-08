import type { Pool, PoolConnection, RowDataPacket, ResultSetHeader } from "mysql2/promise";
import type { ImportInventoryRow } from "../../validators/importDevices.schemas.js";
import { DeviceTypeCode } from "../../types/imports.js";

export type DbConn = Pool | PoolConnection;

export type ImportScope = {
  battalion_id: number | null;
  division_id: number | null;
};

function normSite(site: string): string {
  return String(site ?? "")
    .trim()
    .toUpperCase();
}

/**
 * Minimal state fetch by serial (for "insert vs update" decision).
 */
export async function getCoreDeviceStateBySerial(db: DbConn, serial: string): Promise<{ id: number; lifecycle_status: string; current_unit_id: number | null } | null> {
  const s = String(serial ?? "").trim();
  if (!s) throw new Error("getCoreDeviceStateBySerial: serial is empty");

  const [rows] = await db.query<
    (RowDataPacket & {
      id: number;
      lifecycle_status: string;
      current_unit_id: number | null;
    })[]
  >(
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
 * storage_units:
 * - UNIQUE(storage_site)
 * - We keep unit_name synced
 * - We set battalion_id/division_id when inserting (hardening + future scoping)
 */
export async function getOrCreateStorageUnitIdBySite(db: DbConn, input: { storage_site: string; unit_name: string; scope: ImportScope }): Promise<number> {
  const storageSite = normSite(input.storage_site);
  const unitName = String(input.unit_name ?? "").trim();

  if (!storageSite) throw new Error("getOrCreateStorageUnitIdBySite: storage_site is empty");
  if (!unitName) throw new Error("getOrCreateStorageUnitIdBySite: unit_name is empty");

  const [rows] = await db.query<(RowDataPacket & { id: number; unit_name: string })[]>(
    `
    SELECT id, unit_name
    FROM storage_units
    WHERE storage_site = ? AND is_active = 1
    LIMIT 1
    `,
    [storageSite]
  );

  if (rows[0]?.id) {
    const existing = rows[0];

    // keep name synced
    if (String(existing.unit_name) !== unitName) {
      await db.query<ResultSetHeader>(
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

  const [ins] = await db.query<ResultSetHeader>(
    `
    INSERT INTO storage_units (unit_name, storage_site, battalion_id, division_id, is_active)
    VALUES (?, ?, ?, ?, 1)
    `,
    [unitName, storageSite, input.scope.battalion_id, input.scope.division_id]
  );

  return Number(ins.insertId);
}

/**
 * OPTIONAL (recommended):
 * link makat -> encryption_device_model.id (if table is populated).
 * If not found, returns null (system still works).
 */
export async function getEncryptionModelIdByMakat(db: DbConn, makat: string): Promise<number | null> {
  const m = String(makat ?? "").trim();
  if (!m) return null;

  const [rows] = await db.query<(RowDataPacket & { id: number })[]>(
    `
    SELECT id
    FROM encryption_device_model
    WHERE makat = ? AND is_active = 1
    LIMIT 1
    `,
    [m]
  );

  return rows[0]?.id ? Number(rows[0].id) : null;
}

/**
 * Insert core_device:
 * - columns in schema: serial, makat, device_name, current_unit_id, encryption_model_id
 * - lifecycle_status default is NEW (schema default), but we set explicitly for clarity
 */
export async function insertCoreDevice(db: DbConn, row: ImportInventoryRow, unitId: number, encryptionModelId: number | null): Promise<void> {
  await db.query<ResultSetHeader>(
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
 * Update inventory-only fields.
 * Also revives REMOVED -> ACTIVE when a device reappears.
 */
export async function updateCoreDeviceInventoryOnly(db: DbConn, row: ImportInventoryRow, unitId: number, encryptionModelId: number | null): Promise<"updated" | "unchanged"> {
  const [res] = await db.query<ResultSetHeader>(
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
 * HARDENING: Scoped removal (no global REMOVED).
 * Only remove devices that:
 * - belong to the same battalion/division scope (when present)
 * - and are in storage sites present in the file
 * - and were not present in the file serials
 */
export async function markRemovedMissingSerials(db: DbConn, args: { presentSerials: string[]; storageSites: string[]; scope: ImportScope }): Promise<number> {
  const presentSerials = (args.presentSerials ?? []).map((s) => String(s).trim()).filter(Boolean);
  const storageSites = (args.storageSites ?? []).map(normSite).filter(Boolean);

  // safety guards to prevent disasters on empty/invalid files
  if (presentSerials.length === 0) return 0;
  if (storageSites.length === 0) return 0;

  const sitesPH = storageSites.map(() => "?").join(", ");
  const serialsPH = presentSerials.map(() => "?").join(", ");

  const whereScope: string[] = [];
  const scopeParams: any[] = [];

  if (args.scope.battalion_id !== null) {
    whereScope.push("su.battalion_id = ?");
    scopeParams.push(args.scope.battalion_id);
  }
  if (args.scope.division_id !== null) {
    whereScope.push("su.division_id = ?");
    scopeParams.push(args.scope.division_id);
  }

  const scopeSql = whereScope.length > 0 ? `AND (${whereScope.join(" AND ")})` : "";

  const [res] = await db.query<ResultSetHeader>(
    `
    UPDATE core_device d
    JOIN storage_units su ON su.id = d.current_unit_id
    SET d.lifecycle_status = 'REMOVED'
    WHERE d.deleted_at IS NULL
      AND su.is_active = 1
      AND su.storage_site IN (${sitesPH})
      ${scopeSql}
      AND d.serial NOT IN (${serialsPH})
      AND d.lifecycle_status <> 'REMOVED'
    `,
    [...storageSites, ...scopeParams, ...presentSerials]
  );

  return Number(res.affectedRows ?? 0);
}
