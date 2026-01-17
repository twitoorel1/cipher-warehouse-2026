import type { Pool, RowDataPacket } from "mysql2/promise";
import type { DevicesListQuery } from "@validators/devices.schemas.js";
import { AuthUser, Roles } from "@/types/auth.js";
import { coreDeviceScope } from "@/db/scopes/coreDevice.scope.js";
import { DeviceCardResponse } from "@/services/devices/devices.service.js";

const queryBase = `
    SELECT
      d.id AS device_id,
      d.serial,
      d.makat,
      d.device_name,
      d.lifecycle_status,
      d.current_unit_id,
      DATE_FORMAT(d.battery_life, '%m/%Y') AS battery_life,

      u.id AS unit_id,
      u.unit_name,
      u.storage_site,
      u.battalion_id,

      d.encryption_model_id AS enc_model_id,
      edm.family_id,
      ef.code AS family_code,
      ef.display_name AS family_display_name,
      ef.is_encrypted AS family_is_encrypted,
      edm.carrier_code,

      efr.symbol_scope,
      efr.symbol_global,

      eus.unit_symbol

    FROM core_device d
    
    LEFT JOIN storage_units u ON u.id = d.current_unit_id

    LEFT JOIN encryption_device_model edm ON edm.id = d.encryption_model_id

    LEFT JOIN encryption_family ef ON ef.id = edm.family_id

    LEFT JOIN encryption_family_rule efr ON efr.family_id = ef.id AND efr.is_active = 1

    LEFT JOIN encryption_unit_symbol eus ON eus.family_id = ef.id AND eus.unit_id = d.current_unit_id AND eus.is_active = 1
`;

export type DeviceCardRow = RowDataPacket & {
  device_id: number;
  serial: string;
  makat: string;
  device_name: string;
  lifecycle_status: string;
  current_unit_id: number | null;
  battery_life: string | null;

  unit_id: number | null;
  unit_name: string | null;
  storage_site: string | null;
  battalion_id: number | null;

  enc_model_id: number | null;
  family_id: number | null;
  family_code: string | null;
  family_display_name: string | null;
  family_is_encrypted: number | null;

  carrier_code: string | null;

  symbol_scope: string | null; // 'GLOBAL' | 'PER_UNIT'
  symbol_global: string | null;

  unit_symbol: string | null;
};

function appendScope(whereParts: string[], params: any[], user: AuthUser) {
  const scope = coreDeviceScope(user);
  if (scope.clause && scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    params.push(...scope.params);
  }
}

export type DeviceDbPatch = {
  makat?: string;
  device_name?: string;
  encryption_model_id?: number | null;
  battery_life?: string | null; // YYYY-MM-01 or NULL
  lifecycle_status?: string;
};

export async function updateDeviceByIdScoped(pool: Pool, id: number, patch: DeviceDbPatch, user: AuthUser): Promise<boolean> {
  const setParts: string[] = [];
  const params: any[] = [];

  if (patch.makat !== undefined) {
    setParts.push("d.makat = ?");
    params.push(patch.makat);
  }
  if (patch.device_name !== undefined) {
    setParts.push("d.device_name = ?");
    params.push(patch.device_name);
  }
  if (patch.encryption_model_id !== undefined) {
    setParts.push("d.encryption_model_id = ?");
    params.push(patch.encryption_model_id);
  }
  if (patch.battery_life !== undefined) {
    setParts.push("d.battery_life = ?");
    params.push(patch.battery_life);
  }
  if (patch.lifecycle_status !== undefined) {
    setParts.push("d.lifecycle_status = ?");
    params.push(patch.lifecycle_status);
  }

  if (setParts.length === 0) return false;

  const whereParts: string[] = ["d.id = ?", "d.deleted_at IS NULL"];
  const whereParams: any[] = [id];

  // Enforce scope using CURRENT unit of device (same as reads) — alias u is required by coreDeviceScope
  const scope = coreDeviceScope(user);
  if (scope.clause && scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    whereParams.push(...scope.params);
  }

  const sql = `
    UPDATE core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    SET ${setParts.join(", ")}
    WHERE ${whereParts.join(" AND ")}
  `;

  const [result] = await pool.query(sql, [...params, ...whereParams]);
  const affected = Number((result as any)?.affectedRows ?? 0);
  return affected > 0;
}

export async function getDeviceCardBySerial(pool: Pool, serial: string, user: AuthUser): Promise<DeviceCardRow | null> {
  const s = String(serial).trim();
  if (!s) throw new Error("serial is required");

  const whereParts: string[] = ["d.serial = ?", "d.deleted_at IS NULL"];
  const params: any[] = [s];
  appendScope(whereParts, params, user);

  const [rows] = await pool.query<(RowDataPacket & DeviceCardRow)[]>(
    `
    ${queryBase}

    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    
    `,
    params
  );

  const first = rows[0];
  if (!first) return null;
  return first ?? null;
}

export async function getUnitSymbolForFamilyAndUnit(pool: Pool, familyId: number, unitId: number): Promise<string | null> {
  const [rows] = await pool.query<(RowDataPacket & { unit_symbol: string })[]>(
    `
    SELECT unit_symbol
    FROM encryption_unit_symbol
    WHERE family_id = ?
      AND unit_id = ?
      AND is_active = 1
    LIMIT 1
    `,
    [familyId, unitId]
  );

  const first = rows[0];
  return first ? String(first.unit_symbol) : null;
}

export type PeriodRow = RowDataPacket & {
  period_code: string;
  period_order: number;
};

export async function getActivePeriodsForFamily(pool: Pool, familyId: number, todayISO: string): Promise<PeriodRow[]> {
  const [rows] = await pool.query<PeriodRow[]>(
    `
    SELECT period_code, period_order
    FROM encryption_period
    WHERE family_id = ?
      AND is_active = 1
      AND valid_from <= ?
      AND (valid_to IS NULL OR valid_to >= ?)
    ORDER BY period_order ASC, period_code ASC
    `,
    [familyId, todayISO, todayISO]
  );

  return rows;
}

export async function getDeviceById(pool: Pool, id: number, user: AuthUser): Promise<DeviceCardRow | null> {
  const whereParts: string[] = ["d.id = ?", "d.deleted_at IS NULL"];
  const params: any[] = [id];
  appendScope(whereParts, params, user);

  const [rows] = await pool.query<(RowDataPacket & DeviceCardRow)[]>(
    `
    ${queryBase}

    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    `,
    params
  );

  const first = rows[0];
  if (!first) return null;
  return first ?? null;
}

export function buildWhere(q: DevicesListQuery, user: AuthUser): { whereSql: string; params: any[] } {
  const clauses: string[] = ["d.deleted_at IS NULL"];
  const params: any[] = [];
  appendScope(clauses, params, user);

  // ... כל הפילטרים שכבר יש לך (search, lifecycle_status, device_name, storage_site, battery_life וכו׳)
  if (q.search) {
    clauses.push("(d.serial LIKE ? OR d.makat LIKE ? OR d.device_name LIKE ?)");
    const like = `%${q.search}%`;
    params.push(like, like, like);
  }

  if (q.lifecycle_status) {
    clauses.push("d.lifecycle_status = ?");
    params.push(q.lifecycle_status);
  }

  if (q.device_name) {
    clauses.push("d.device_name LIKE ?");
    const likeName = `%${q.device_name}%`;
    params.push(likeName);
  }

  if (q.storage_site) {
    clauses.push(`d.current_unit_id IN (
      SELECT id FROM storage_units WHERE storage_site LIKE ?
    )`);
    const likeUnit = `%${q.storage_site}%`;
    params.push(likeUnit);
  }

  const whereSql: string = clauses.length ? `WHERE ${clauses.join(" AND ")}` : "";

  return { whereSql, params };
}

export async function countDevices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<number> {
  const { whereSql, params } = buildWhere(q, user);

  const [rows] = await pool.query<(RowDataPacket & { total: number })[]>(
    `
    SELECT COUNT(*) AS total
    FROM core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    ${whereSql}
    `,
    params
  );

  return Number(rows[0]?.total ?? 0);
}

const SORT_COLUMN_MAP: Record<DevicesListQuery["sort_by"], string> = {
  updated_at: "d.updated_at",
  created_at: "d.created_at",
  device_name: "d.device_name",
  makat: "d.makat",
  serial: "d.serial",
};

export async function listDevices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<DeviceCardRow[] | null> {
  const { whereSql, params } = buildWhere(q, user);

  const sortCol = SORT_COLUMN_MAP[q.sort_by];
  const sortDir = q.sort_order.toUpperCase() === "ASC" ? "ASC" : "DESC";
  const offset = (q.page - 1) * q.limit;

  const [rows] = await pool.query<(RowDataPacket & DeviceCardRow)[]>(
    `
    ${queryBase}

    ${whereSql}
    ORDER BY ${sortCol} ${sortDir}
    LIMIT ?
    OFFSET ?
    `,
    [...params, q.limit, offset]
  );

  if (!rows) return null;
  return rows ?? null;
}

//
//
//
//
//
//
//
//
//
// TEL100 constants
const TEL100_VOICE_MAKAT = "309418000";
const TEL100_MODEM_MAKATS = ["309415906", "309418100"] as const;

export type Tel100ListRow = RowDataPacket & {
  device_id: number;
  serial: string;
  makat: string;
  device_name: string;
  lifecycle_status: string;
  battery_life: string | null;

  unit_id: number | null;
  unit_name: string | null;
  storage_site: string | null;

  has_voice_profile: number; // 0/1
  has_modem_profile: number; // 0/1
};

export async function countTel100Devices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<number> {
  const clauses: string[] = ["d.deleted_at IS NULL", "d.makat IN (?, ?, ?)"];
  const params: any[] = [TEL100_VOICE_MAKAT, ...TEL100_MODEM_MAKATS];

  appendScope(clauses, params, user);

  if (q.search) {
    clauses.push("(d.serial LIKE ? OR d.device_name LIKE ?)");
    const like = `%${q.search}%`;
    params.push(like, like);
  }

  const whereSql = `WHERE ${clauses.join(" AND ")}`;

  const [rows] = await pool.query<(RowDataPacket & { total: number })[]>(
    `
    SELECT COUNT(*) AS total
    FROM core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    ${whereSql}
    `,
    params
  );

  return Number(rows[0]?.total ?? 0);
}

export async function listTel100Devices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<Tel100ListRow[]> {
  const clauses: string[] = ["d.deleted_at IS NULL", "d.makat IN (?, ?, ?)"];
  const params: any[] = [TEL100_VOICE_MAKAT, ...TEL100_MODEM_MAKATS];

  appendScope(clauses, params, user);

  if (q.search) {
    clauses.push("(d.serial LIKE ? OR d.device_name LIKE ?)");
    const like = `%${q.search}%`;
    params.push(like, like);
  }

  const whereSql = `WHERE ${clauses.join(" AND ")}`;

  const sortCol = SORT_COLUMN_MAP[q.sort_by];
  const sortDir = q.sort_order.toUpperCase() === "ASC" ? "ASC" : "DESC";
  const offset = (q.page - 1) * q.limit;

  // DATE_FORMAT(d.battery_life, '%m/%Y') AS battery_life,
  const [rows] = await pool.query<Tel100ListRow[]>(
    `
    SELECT
      d.id AS device_id,
      d.serial,
      d.makat,
      d.device_name,
      d.lifecycle_status,

      u.id AS unit_id,
      u.unit_name,
      u.storage_site,

      CASE WHEN vp.core_device_id IS NULL THEN 0 ELSE 1 END AS has_voice_profile,
      CASE WHEN mp.core_device_id IS NULL THEN 0 ELSE 1 END AS has_modem_profile

    FROM core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    LEFT JOIN tel100_voice_profile vp ON vp.core_device_id = d.id
    LEFT JOIN tel100_modem_profile mp ON mp.core_device_id = d.id
    ${whereSql}
    ORDER BY ${sortCol} ${sortDir}
    LIMIT ?
    OFFSET ?
    `,
    [...params, q.limit, offset]
  );

  return rows ?? [];
}
