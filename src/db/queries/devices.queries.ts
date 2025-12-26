import type { Pool, RowDataPacket } from "mysql2/promise";
import type { DevicesListQuery } from "../../validators/devices.schemas.js";
import { CoreDeviceRow } from "../../types/devices.js";

export type DeviceCardRow = RowDataPacket & {
  device_id: number;
  serial: string;
  makat: string;
  device_name: string;
  lifecycle_status: string;
  current_unit_id: number | null;

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

export async function getDeviceCardBySerial(pool: Pool, serial: string): Promise<DeviceCardRow | null> {
  const s = String(serial).trim();
  if (!s) throw new Error("serial is required");

  const [rows] = await pool.query<DeviceCardRow[]>(
    `
    SELECT
      d.id AS device_id,
      d.serial,
      d.makat,
      d.device_name,
      d.lifecycle_status,
      d.current_unit_id,

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
    LEFT JOIN storage_units u
      ON u.id = d.current_unit_id

    LEFT JOIN encryption_device_model edm
      ON edm.id = d.encryption_model_id

    LEFT JOIN encryption_family ef
      ON ef.id = edm.family_id

    LEFT JOIN encryption_family_rule efr
      ON efr.family_id = ef.id AND efr.is_active = 1

    LEFT JOIN encryption_unit_symbol eus
      ON eus.family_id = ef.id
     AND eus.unit_id = d.current_unit_id
     AND eus.is_active = 1

    WHERE d.serial = ?
      AND d.deleted_at IS NULL
    LIMIT 1
    `,
    [s]
  );

  const first = rows[0];
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

// Olders
// const SORT_COLUMN_MAP: Record<DevicesListQuery["sort_by"], string> = {
//   updated_at: "d.updated_at",
//   created_at: "d.created_at",
//   device_name: "d.device_name",
//   makat: "d.makat",
//   serial: "d.serial",
// };

// export async function countDevices(pool: Pool, q: DevicesListQuery): Promise<number> {
//   const { whereSql, params } = buildWhere(q);
//   const [rows] = await pool.query<(RowDataPacket & { total: number })[]>(
//     `
//     SELECT COUNT(*) AS total
//     FROM core_device d
//     INNER JOIN device_type dt ON dt.id = d.device_type_id
//     ${whereSql}
//     `,
//     params
//   );

//   return Number(rows[0]?.total ?? 0);
// }

// export async function listDevices(pool: Pool, q: DevicesListQuery): Promise<CoreDeviceRow[]> {
//   const { whereSql, params } = buildWhere(q);

//   const sortCol = SORT_COLUMN_MAP[q.sort_by];
//   const sortDir = q.sort_order.toUpperCase() === "ASC" ? "ASC" : "DESC";
//   const offset = (q.page - 1) * q.limit;

//   const [rows] = await pool.query<(RowDataPacket & CoreDeviceRow)[]>(
//     `
//     SELECT
//       d.id,
//       d.serial,
//       d.makat,
//       d.device_name,
//       d.current_unit_symbol,
//       d.lifecycle_status,
//       d.created_at,
//       d.updated_at,
//       d.deleted_at,

//       dt.id AS dt_id,
//       dt.code AS dt_code,
//       dt.display_name AS dt_display_name,

//       ep.id AS ep_id,
//       ep.profile_name AS ep_profile_name

//     FROM core_device d

//     INNER JOIN device_type dt ON dt.id = d.device_type_id
//     INNER JOIN encryption_profile ep ON ep.id = d.encryption_profile_id
//     ${whereSql}
//     ORDER BY ${sortCol} ${sortDir}
//     LIMIT ?
//     OFFSET ?
//     `,
//     [...params, q.limit, offset]
//   );

//   // ${whereSql} == WHERE d.deleted_at IS NULL AND d.lifecycle_status = ?

//   return rows.map((r) => ({
//     id: r.id,
//     serial: r.serial,
//     makat: r.makat,
//     device_name: r.device_name,
//     current_unit_symbol: r.current_unit_symbol,
//     lifecycle_status: r.lifecycle_status,

//     device_type_id: {
//       id: r.dt_id,
//       code: r.dt_code,
//       display_name: r.dt_display_name,
//     },

//     encryption_profile_id: {
//       id: r.ep_id,
//       profile_name: r.ep_profile_name,
//     },

//     created_at: r.created_at,
//     updated_at: r.updated_at,
//   }));
// }

// export async function getDeviceById(pool: Pool, id: number): Promise<CoreDeviceRow | null> {
//   const [rows] = await pool.query<(RowDataPacket & CoreDeviceRow)[]>(
//     `
//     SELECT
//       d.id,
//       d.serial,
//       d.makat,
//       d.device_name,
//       d.current_unit_symbol,
//       d.lifecycle_status,
//       d.created_at,
//       d.updated_at,
//       d.deleted_at,

//       dt.id AS dt_id,
//       dt.code AS dt_code,
//       dt.display_name AS dt_display_name,

//       ep.id AS ep_id,
//       ep.profile_name AS ep_profile_name

//     FROM core_device d

//     INNER JOIN device_type dt ON dt.id = d.device_type_id
//     INNER JOIN encryption_profile ep ON ep.id = d.encryption_profile_id
//     WHERE d.id = ?
//     LIMIT 1
//     `,
//     [id]
//   );

//   const r = rows[0];
//   if (!r) return null;
//   if (r.deleted_at !== null) return null;

//   return {
//     id: r.id,
//     serial: r.serial,
//     makat: r.makat,
//     device_name: r.device_name,
//     current_unit_symbol: r.current_unit_symbol,
//     lifecycle_status: r.lifecycle_status,

//     device_type_id: {
//       id: r.dt_id,
//       code: r.dt_code,
//       display_name: r.dt_display_name,
//     },
//     encryption_profile_id: {
//       id: r.ep_id,
//       profile_name: r.ep_profile_name,
//     },

//     created_at: r.created_at,
//     updated_at: r.updated_at,
//   };
// }

// function buildWhere(q: DevicesListQuery): { whereSql: string; params: any[] } {
//   const clauses: string[] = ["d.deleted_at IS NULL"];
//   const params: any[] = [];

//   if (q.search) {
//     clauses.push("(d.serial LIKE ? OR d.makat LIKE ? OR d.device_name LIKE ?)");
//     const like = `%${q.search}%`;
//     params.push(like, like, like);
//   }

//   if (q.lifecycle_status) {
//     clauses.push("d.lifecycle_status = ?");
//     params.push(q.lifecycle_status);
//   }

//   return {
//     whereSql: clauses.length ? `WHERE ${clauses.join(" AND ")}` : "",
//     params,
//   };
// }
