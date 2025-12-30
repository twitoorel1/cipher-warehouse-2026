import type { Pool, RowDataPacket } from "mysql2/promise";
import type { DevicesListQuery } from "../../validators/devices.schemas.js";
import { AuthUser, Roles } from "../../types/auth.js";
import { coreDeviceScope } from "../scopes/coreDevice.scope.js";

const queryBase = `
    SELECT
      d.id AS device_id,
      d.serial,
      d.makat,
      d.device_name,
      d.lifecycle_status,
      d.current_unit_id,
      DATE_FORMAT(d.battery_life, '%m/%Y') AS battery_life,
      d.battalion_id,
      d.division_id,

      u.id AS unit_id,
      u.unit_name,
      u.storage_site,

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

// function scopeClauseForCoreDevice(user: AuthUser): { clause: string; params: any[] } {
//   // Admins can see all devices
//   if (user.role === Roles.ADMIN) return { clause: "", params: [] };

//   // User Battalion
//   if (String(user.role).startsWith("BATTALION_")) {
//     if (!user.battalion_id) return { clause: "1=0", params: [] }; // no access
//     return { clause: "d.battalion_id = ?", params: [user.battalion_id] };
//   }

//   // User Division
//   if (String(user.role).startsWith("DIVISION_")) {
//     if (!user.division_id) return { clause: "1=0", params: [] }; // no access
//     return {
//       clause: `
//         EXISTS (
//           SELECT 1
//           FROM battalions b
//           WHERE b.id = d.battalion_id
//             AND b.division_id = ?
//         )
//       `,
//       params: [user.division_id],
//     };
//   }

//   // Role לא מזוהה > חסימה
//   return { clause: "1=0", params: [] };
// }

const SORT_COLUMN_MAP: Record<DevicesListQuery["sort_by"], string> = {
  updated_at: "d.updated_at",
  created_at: "d.created_at",
  device_name: "d.device_name",
  makat: "d.makat",
  serial: "d.serial",
};

export function buildWhere(q: DevicesListQuery, user: AuthUser): { whereSql: string; params: any[] } {
  const clauses: string[] = ["d.deleted_at IS NULL"];
  const params: any[] = [];

  const scope = coreDeviceScope(user);
  if (scope.clause) {
    // clauses.push(`(${scope.clause})`);
    clauses.push(scope.clause);
    params.push(...scope.params);
  }

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

  let whereSql: string = clauses.length ? `WHERE ${clauses.join(" AND ")}` : "";

  return {
    whereSql,
    params,
  };
}

export async function getDeviceCardBySerial(pool: Pool, serial: string): Promise<DeviceCardRow | null> {
  const s = String(serial).trim();
  if (!s) throw new Error("serial is required");

  const [rows] = await pool.query<DeviceCardRow[]>(
    `
    ${queryBase}

    WHERE d.serial = ?
    AND d.deleted_at IS NULL
    LIMIT 1
    `,
    [s]
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
  // todayISO should be YYYY-MM-DD
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
  const scope = scopeClauseForCoreDevice(user);
  const whereParts: string[] = ["d.id = ?", "d.deleted_at IS NULL"];
  const params: any[] = [id];

  if (scope.clause) {
    whereParts.push(scope.clause);
    params.push(...scope.params);
  }

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

function buildWhere2(q: DevicesListQuery): { whereSql: string; params: any[] } {
  const clauses: string[] = ["d.deleted_at IS NULL"];
  const params: any[] = [];

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

  let whereSql: string = clauses.length ? `WHERE ${clauses.join(" AND ")}` : "";

  return {
    whereSql,
    params,
  };
}

export async function countDevices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<number> {
  const { whereSql, params } = buildWhere(q, user);
  const [rows] = await pool.query<(RowDataPacket & { total: number })[]>(
    `
    SELECT COUNT(*) AS total
    FROM core_device d
    ${whereSql}
    `,
    params
  );

  // INNER JOIN device_type dt ON dt.id = d.device_type_id
  return Number(rows[0]?.total ?? 0);
}

// export async function listDevices(pool: Pool, q: DevicesListQuery): Promise<DeviceCardRow[] | null> {
export async function listDevices(pool: Pool, q: DevicesListQuery, user: AuthUser): Promise<DeviceCardRow[] | null> {
  const { whereSql, params } = buildWhere(q, user);

  const sortCol = SORT_COLUMN_MAP[q.sort_by];
  const sortDir = q.sort_order.toUpperCase() === "ASC" ? "ASC" : "DESC";
  const offset = (q.page - 1) * q.limit;

  const [rows] = await pool.query<DeviceCardRow[]>(
    `
    ${queryBase}

    ${whereSql}
    ORDER BY ${sortCol} ${sortDir}
    LIMIT ?
    OFFSET ?
    `,
    [...params, q.limit, offset]
  );

  // console.log(params);
  // console.log(whereSql);

  if (!rows) return null;
  return rows ?? null;
}
