import type { Pool } from "mysql2/promise";
import type { DevicesListQuery } from "../../validators/devices.schemas.js";
import { getDeviceCardBySerial, getUnitSymbolForFamilyAndUnit, getActivePeriodsForFamily } from "../../db/queries/devices.queries.js";

function toISODateOnly(d: Date): string {
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(d.getUTCDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

export type DeviceCardResponse = {
  device: {
    id: number;
    serial: string;
    makat: string;
    device_name: string;
    lifecycle_status: string;
    current_unit: null | {
      id: number;
      unit_name: string;
      storage_site: string;
    };
    encryption: null | {
      is_encrypted: boolean;
      family: { code: string; display_name: string };
      carrier_code: string | null;
      symbol_scope: "GLOBAL" | "PER_UNIT";
      symbol: string | null;
      periods: { code: string; order: number }[];
    };
  };
};

export async function getDeviceCardBySerialService(pool: Pool, serial: string): Promise<DeviceCardResponse | null> {
  const row = await getDeviceCardBySerial(pool, serial);
  if (!row) return null;

  const currentUnit = row.unit_id && row.unit_name && row.storage_site ? { id: Number(row.unit_id), unit_name: String(row.unit_name), storage_site: String(row.storage_site) } : null;

  // If we don't have encryption model/family, encryption is null
  if (!row.family_id || !row.family_code || !row.family_display_name || row.family_is_encrypted === null) {
    return {
      device: {
        id: Number(row.device_id),
        serial: String(row.serial),
        makat: String(row.makat),
        device_name: String(row.device_name),
        lifecycle_status: String(row.lifecycle_status),
        current_unit: currentUnit,
        encryption: null,
      },
    };
  }

  const familyId = Number(row.family_id);
  const symbolScope = String(row.symbol_scope || "GLOBAL") as "GLOBAL" | "PER_UNIT";
  const isEncrypted = Number(row.family_is_encrypted) === 1;

  let symbol: string | null = null;

  if (symbolScope === "GLOBAL") {
    symbol = row.symbol_global ? String(row.symbol_global) : null;
  } else {
    // PER_UNIT
    if (row.current_unit_id) {
      symbol = await getUnitSymbolForFamilyAndUnit(pool, Number(familyId), Number(row.current_unit_id));
    } else {
      symbol = null;
    }
  }

  const todayISO = toISODateOnly(new Date());
  const periodsRows = await getActivePeriodsForFamily(pool, familyId, todayISO);
  const periods = periodsRows.map((p) => ({ code: String(p.period_code), order: Number(p.period_order) }));

  return {
    device: {
      id: Number(row.device_id),
      serial: String(row.serial),
      makat: String(row.makat),
      device_name: String(row.device_name),
      lifecycle_status: String(row.lifecycle_status),
      current_unit: currentUnit,
      encryption: {
        is_encrypted: isEncrypted,
        family: { code: String(row.family_code), display_name: String(row.family_display_name) },
        carrier_code: row.carrier_code ? String(row.carrier_code) : null,
        symbol_scope: symbolScope,
        symbol,
        periods,
      },
    },
  };
}

// Olders
// export async function getDevicesList(pool: Pool, q: DevicesListQuery) {
//   const total = await countDevices(pool, q);
//   const items = await listDevices(pool, q);
//   const total_pages = Math.ceil(total / q.limit);

//   return {
//     items,
//     page: q.page,
//     limit: q.limit,
//     total,
//     total_pages,
//   };
// }

// export async function getDeviceDetails(pool: Pool, id: number) {
//   return getDeviceById(pool, id);
// }
