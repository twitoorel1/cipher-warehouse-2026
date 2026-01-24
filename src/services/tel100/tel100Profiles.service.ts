import type { Pool } from "mysql2/promise";
import type { AuthUser } from "@/types/auth.js"; // תתאים path
import type { Keyring } from "@/crypto/keyring.js"; // תתאים path
import { encryptUtf8, EncryptedBundle, decryptUtf8 } from "@/crypto/fieldCrypto.js"; // זה הקובץ שלך
import { getTel100ModemProfileQuery, updateTel100ModemProfileQuery, updateTel100VoiceProfileQuery } from "../../db/queries/tel100Profiles.queries.js";
import { AppError } from "@/middleware/error.middleware.js";
import { can } from "@/rbac/can.js";
import { Permissions } from "@/types/permissions.js";

function encOpt(keyring: Keyring, plaintext: string | null | undefined, aad: string): EncryptedBundle | null | undefined {
  if (plaintext === undefined) return undefined; // לא נוגעים
  if (plaintext === null) return null; // מנקים (NULL)
  return encryptUtf8(keyring, plaintext, aad);
}

export async function updateTel100VoiceProfileService(
  pool: Pool,
  keyring: Keyring,
  user: AuthUser,
  input: {
    coreDeviceId: number;

    full_name?: string | null;
    user_type?: "PERMANENT" | "RESERVE" | "OTHER" | null;
    personal_number?: string | null;
    job_title?: string | null;
    phone_number?: string | null;
    ptt_status?: "OK" | "NOT_OK" | "UNKNOWN";

    // plaintext נכנס — מוצפן בשירות
    ptt_group?: string | null;
    hub_password?: string | null;
    operational_auth_code?: string | null;
    device_pin?: string | null;
    opening_template?: string | null;

    sim_black?: string | null;
    sim_red_binding_id?: string | null;
    sim_red_copy_marking_short?: string | null;
    sim_red_copy_marking_long?: string | null;
  }
) {
  const aadBase = `tel100_voice_profile:${input.coreDeviceId}`;

  const queryData: {
    coreDeviceId: number;

    fullName?: string | null;
    userType?: "PERMANENT" | "RESERVE" | "OTHER" | null;
    personalNumber?: string | null;
    jobTitle?: string | null;
    phoneNumber?: string | null;
    pttStatus?: "OK" | "NOT_OK" | "UNKNOWN";

    pttGroup?: EncryptedBundle | null;
    hubPassword?: EncryptedBundle | null;
    operationalAuthCode?: EncryptedBundle | null;
    devicePin?: EncryptedBundle | null;
    openingTemplate?: EncryptedBundle | null;

    simBlack?: EncryptedBundle | null;
    simRedBindingId?: EncryptedBundle | null;
    simRedCopyMarkingShort?: EncryptedBundle | null;
    simRedCopyMarkingLong?: EncryptedBundle | null;
  } = {
    coreDeviceId: input.coreDeviceId,
  };

  // plaintext
  if (input.full_name !== undefined) queryData.fullName = input.full_name;
  if (input.user_type !== undefined) queryData.userType = input.user_type;
  if (input.personal_number !== undefined) queryData.personalNumber = input.personal_number;
  if (input.job_title !== undefined) queryData.jobTitle = input.job_title;
  if (input.phone_number !== undefined) queryData.phoneNumber = input.phone_number;
  if (input.ptt_status !== undefined) queryData.pttStatus = input.ptt_status;

  // encrypted bundles
  const pttGroup = encOpt(keyring, input.ptt_group, `${aadBase}:ptt_group`);
  if (pttGroup !== undefined) queryData.pttGroup = pttGroup;

  const hubPassword = encOpt(keyring, input.hub_password, `${aadBase}:hub_password`);
  if (hubPassword !== undefined) queryData.hubPassword = hubPassword;

  const operationalAuthCode = encOpt(keyring, input.operational_auth_code, `${aadBase}:operational_auth_code`);
  if (operationalAuthCode !== undefined) queryData.operationalAuthCode = operationalAuthCode;

  const devicePin = encOpt(keyring, input.device_pin, `${aadBase}:device_pin`);
  if (devicePin !== undefined) queryData.devicePin = devicePin;

  const openingTemplate = encOpt(keyring, input.opening_template, `${aadBase}:opening_template`);
  if (openingTemplate !== undefined) queryData.openingTemplate = openingTemplate;

  const simBlack = encOpt(keyring, input.sim_black, `${aadBase}:sim_black`);
  if (simBlack !== undefined) queryData.simBlack = simBlack;

  const simRedBindingId = encOpt(keyring, input.sim_red_binding_id, `${aadBase}:sim_red_binding_id`);
  if (simRedBindingId !== undefined) queryData.simRedBindingId = simRedBindingId;

  const simRedCopyMarkingShort = encOpt(keyring, input.sim_red_copy_marking_short, `${aadBase}:sim_red_copy_marking_short`);
  if (simRedCopyMarkingShort !== undefined) queryData.simRedCopyMarkingShort = simRedCopyMarkingShort;

  const simRedCopyMarkingLong = encOpt(keyring, input.sim_red_copy_marking_long, `${aadBase}:sim_red_copy_marking_long`);
  if (simRedCopyMarkingLong !== undefined) queryData.simRedCopyMarkingLong = simRedCopyMarkingLong;

  // await updateTel100VoiceProfileQuery(pool, queryData, user);
  const r = await updateTel100VoiceProfileQuery(pool, queryData, user);
  if (!r || (r as any).affectedRows === 0) {
    throw new AppError({
      code: "FORBIDDEN",
      status: 403,
      message: "Device is out of scope or voice profile not found",
    });
  }
}

function enc(keyring: Keyring, aadBase: string, field: string, v: string | null | undefined): EncryptedBundle | null | undefined {
  if (v === undefined) return undefined;
  if (v === null) return null;
  return encryptUtf8(keyring, v, `${aadBase}:${field}`);
}

export async function updateTel100ModemProfileService(
  pool: Pool,
  keyring: Keyring,
  user: AuthUser,
  input: {
    coreDeviceId: number;
    hamal_user?: string | null;
    job_title?: string | null;

    sim_black?: string | null;
    sim_red_binding_id?: string | null;
    sim_red_copy_marking_short?: string | null;
    sim_red_copy_marking_long?: string | null;
  }
) {
  const aadBase = `tel100_modem_profile:${input.coreDeviceId}`;

  const queryData: {
    coreDeviceId: number;
    hamalUser?: string | null;
    jobTitle?: string | null;

    simBlack?: EncryptedBundle | null;
    simRedBindingId?: EncryptedBundle | null;
    simRedCopyMarkingShort?: EncryptedBundle | null;
    simRedCopyMarkingLong?: EncryptedBundle | null;
  } = { coreDeviceId: input.coreDeviceId };

  if (input.hamal_user !== undefined) queryData.hamalUser = input.hamal_user;
  if (input.job_title !== undefined) queryData.jobTitle = input.job_title;

  const b1 = enc(keyring, aadBase, "sim_black", input.sim_black);
  const b2 = enc(keyring, aadBase, "sim_red_binding_id", input.sim_red_binding_id);
  const b3 = enc(keyring, aadBase, "sim_red_copy_marking_short", input.sim_red_copy_marking_short);
  const b4 = enc(keyring, aadBase, "sim_red_copy_marking_long", input.sim_red_copy_marking_long);

  if (b1 !== undefined) queryData.simBlack = b1;
  if (b2 !== undefined) queryData.simRedBindingId = b2;
  if (b3 !== undefined) queryData.simRedCopyMarkingShort = b3;
  if (b4 !== undefined) queryData.simRedCopyMarkingLong = b4;

  const r = await updateTel100ModemProfileQuery(pool, queryData, user);

  if (!r || r.affectedRows === 0) {
    throw new AppError({
      code: "FORBIDDEN",
      status: 403,
      message: "Device is out of scope or modem profile not found",
    });
  }
}

export async function getTel100ModemProfileService(pool: Pool, keyring: Keyring, user: AuthUser, coreDeviceId: number) {
  // הרשאת בסיס
  can(user, Permissions.TEL100_MODEM_VIEW, { silent: false });

  const row = await getTel100ModemProfileQuery(pool, coreDeviceId, user);
  if (!row) return null;

  const allowPlaintext = can(user, Permissions.TEL100_MODEM_VIEW_PLAINTEXT, { silent: true });
  const aadBase = `tel100_modem_profile:${coreDeviceId}`;

  return {
    core_device_id: row.core_device_id,
    serial: row.serial,
    device_name: row.device_name,
    makat: row.makat,

    current_unit: {
      id: row.current_unit_id,
      unit_name: row.current_unit_name,
      storage_site: row.current_storage_site,
    },

    hamal_user: row.hamal_user,
    job_title: row.job_title,

    sim_black:
      allowPlaintext && row.sim_black_ct
        ? decryptUtf8(
            keyring,
            {
              ct: row.sim_black_ct,
              iv: row.sim_black_iv,
              tag: row.sim_black_tag,
              kv: row.sim_black_kv,
            },
            `${aadBase}:sim_black`
          )
        : null,

    sim_red_binding_id:
      allowPlaintext && row.sim_red_binding_id_ct
        ? decryptUtf8(
            keyring,
            {
              ct: row.sim_red_binding_id_ct,
              iv: row.sim_red_binding_id_iv,
              tag: row.sim_red_binding_id_tag,
              kv: row.sim_red_binding_id_kv,
            },
            `${aadBase}:sim_red_binding_id`
          )
        : null,

    sim_red_copy_marking_short:
      allowPlaintext && row.sim_red_copy_marking_short_ct
        ? decryptUtf8(
            keyring,
            {
              ct: row.sim_red_copy_marking_short_ct,
              iv: row.sim_red_copy_marking_short_iv,
              tag: row.sim_red_copy_marking_short_tag,
              kv: row.sim_red_copy_marking_short_kv,
            },
            `${aadBase}:sim_red_copy_marking_short`
          )
        : null,

    sim_red_copy_marking_long:
      allowPlaintext && row.sim_red_copy_marking_long_ct
        ? decryptUtf8(
            keyring,
            {
              ct: row.sim_red_copy_marking_long_ct,
              iv: row.sim_red_copy_marking_long_iv,
              tag: row.sim_red_copy_marking_long_tag,
              kv: row.sim_red_copy_marking_long_kv,
            },
            `${aadBase}:sim_red_copy_marking_long`
          )
        : null,

    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}
