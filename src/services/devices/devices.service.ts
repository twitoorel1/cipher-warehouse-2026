import type { Pool } from "mysql2/promise";
import type { DevicePatchBody, DevicesListQuery } from "@validators/devices.schemas.js";
import { getDeviceCardBySerial, getUnitSymbolForFamilyAndUnit, getActivePeriodsForFamily, getDeviceById, countDevices, listDevices, updateDeviceByIdScoped } from "@db/queries/devices.queries.js";
import { CoreDeviceRow } from "@/types/devices.js";
import { AuthUser } from "@/types/auth.js";
import { countTel100Devices, listTel100Devices } from "@db/queries/devices.queries.js";

export async function getTel100DevicesList(pool: Pool, q: DevicesListQuery, user: AuthUser) {
  const total = await countTel100Devices(pool, q, user);
  const items = await listTel100Devices(pool, q, user);
  const total_pages = Math.ceil(total / q.limit);

  return {
    items,
    page: q.page,
    limit: q.limit,
    total,
    total_pages,
  };
}

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
    battery_life: string | null;
    current_unit: null | {
      id: number;
      unit_name: string;
      storage_site: string;
      // battalion_id: number;
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

function parseMmYYYYToISODate(monthYear: string): string {
  const m = String(monthYear).trim();
  const mm = Number(m.slice(0, 2));
  const yyyy = Number(m.slice(3));
  if (!Number.isInteger(mm) || mm < 1 || mm > 12 || !Number.isInteger(yyyy) || yyyy < 1900 || yyyy > 2100) {
    throw new Error("battery_life must be in MM/YYYY");
  }
  const mmStr = String(mm).padStart(2, "0");
  return `${yyyy}-${mmStr}-01`;
}

export async function updateDeviceByIdService(pool: Pool, id: number, patch: DevicePatchBody, user: AuthUser): Promise<DeviceCardResponse | null> {
  const dbPatch: {
    makat?: string;
    device_name?: string;
    encryption_model_id?: number | null;
    battery_life?: string | null;
    lifecycle_status?: DevicePatchBody["lifecycle_status"];
  } = {};

  if (patch.makat !== undefined) dbPatch.makat = patch.makat;
  if (patch.device_name !== undefined) dbPatch.device_name = patch.device_name;
  if (patch.encryption_model_id !== undefined) dbPatch.encryption_model_id = patch.encryption_model_id;
  if (patch.lifecycle_status !== undefined) dbPatch.lifecycle_status = patch.lifecycle_status;

  if (patch.battery_life !== undefined) {
    if (patch.battery_life === null) {
      dbPatch.battery_life = null;
    } else {
      dbPatch.battery_life = parseMmYYYYToISODate(patch.battery_life);
    }
  }

  // Remove undefined properties to match DeviceDbPatch type
  const cleanDbPatch = Object.fromEntries(Object.entries(dbPatch).filter(([_, value]) => value !== undefined));

  const changed = await updateDeviceByIdScoped(pool, id, cleanDbPatch, user);
  if (!changed) return null;

  return await getDeviceDetails(pool, id, user);
}

export async function getDeviceCardBySerialService(pool: Pool, serial: string, user: AuthUser): Promise<DeviceCardResponse | null> {
  const row = await getDeviceCardBySerial(pool, serial, user);
  if (!row) return null;

  const currentUnit =
    row.unit_id && row.unit_name && row.storage_site
      ? {
          id: Number(row.unit_id),
          unit_name: String(row.unit_name),
          storage_site: String(row.storage_site),
        }
      : null;

  // If we don't have encryption model/family, encryption is null
  if (!row.family_id || !row.family_code || !row.family_display_name || row.family_is_encrypted === null) {
    return {
      device: {
        id: Number(row.device_id),
        serial: String(row.serial),
        makat: String(row.makat),
        device_name: String(row.device_name),
        lifecycle_status: String(row.lifecycle_status),
        battery_life: row.battery_life ? String(row.battery_life) : null,
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
      battery_life: row.battery_life ? String(row.battery_life) : null,
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

export async function getDeviceDetails(pool: Pool, id: number, user: AuthUser): Promise<DeviceCardResponse | null> {
  const row = await getDeviceById(pool, id, user);
  if (!row) return null;

  const currentUnit =
    row.unit_id && row.unit_name && row.storage_site
      ? {
          id: Number(row.unit_id),
          unit_name: String(row.unit_name),
          storage_site: String(row.storage_site),
        }
      : null;

  // If we don't have encryption model/family, encryption is null
  if (!row.family_id || !row.family_code || !row.family_display_name || row.family_is_encrypted === null) {
    return {
      device: {
        id: Number(row.device_id),
        serial: String(row.serial),
        makat: String(row.makat),
        device_name: String(row.device_name),
        lifecycle_status: String(row.lifecycle_status),
        battery_life: row.battery_life ? String(row.battery_life) : null,
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
      battery_life: row.battery_life ? String(row.battery_life) : null,
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

export async function getDevicesList(pool: Pool, q: DevicesListQuery, user: AuthUser) {
  const total = await countDevices(pool, q, user);
  const items = await listDevices(pool, q, user);
  const total_pages = Math.ceil(total / q.limit);

  return {
    items,
    page: q.page,
    limit: q.limit,
    total,
    total_pages,
  };
}
