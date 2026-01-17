import type { Pool, ResultSetHeader } from "mysql2/promise";
import { coreDeviceScope } from "../scopes/coreDevice.scope.js";
import type { AuthUser } from "@/types/auth.js";
import { EncryptedBundle } from "@/crypto/fieldCrypto.js";

export async function getTel100VoiceProfile(pool: Pool, params: { coreDeviceId: number; user: AuthUser }) {
  const scope = coreDeviceScope(params.user);

  const whereParts: string[] = ["vp.core_device_id = ?", "d.deleted_at IS NULL"];
  const sqlParams: any[] = [params.coreDeviceId];

  if (scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    sqlParams.push(...scope.params);
  }

  const [rows] = await pool.query(
    `SELECT
      vp.core_device_id,
      d.serial,
      d.device_name,
      d.makat,
      
      u.id AS current_unit_id,
      u.unit_name AS current_unit_name,
      u.storage_site AS current_storage_site,

      vp.full_name,
      vp.user_type,
      vp.personal_number,
      vp.job_title,
      vp.phone_number,
      vp.ptt_status,
      vp.ptt_group_ct, vp.ptt_group_iv, vp.ptt_group_tag, vp.ptt_group_kv,
      vp.hub_password_ct, vp.hub_password_iv, vp.hub_password_tag, vp.hub_password_kv,
      vp.operational_auth_code_ct, vp.operational_auth_code_iv, vp.operational_auth_code_tag, vp.operational_auth_code_kv,
      vp.device_pin_ct, vp.device_pin_iv, vp.device_pin_tag, vp.device_pin_kv,
      vp.opening_template_ct, vp.opening_template_iv, vp.opening_template_tag, vp.opening_template_kv,
      vp.sim_black_ct, vp.sim_black_iv, vp.sim_black_tag, vp.sim_black_kv,
      vp.sim_red_binding_id_ct, vp.sim_red_binding_id_iv, vp.sim_red_binding_id_tag, vp.sim_red_binding_id_kv,
      vp.sim_red_copy_marking_short_ct, vp.sim_red_copy_marking_short_iv, vp.sim_red_copy_marking_short_tag, vp.sim_red_copy_marking_short_kv,
      vp.sim_red_copy_marking_long_ct, vp.sim_red_copy_marking_long_iv, vp.sim_red_copy_marking_long_tag, vp.sim_red_copy_marking_long_kv,
      vp.created_at,
      vp.updated_at

    FROM tel100_voice_profile vp
    JOIN core_device d ON d.id = vp.core_device_id
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    
    `,
    sqlParams
  );

  return (rows as any[])[0] || null;
}

export async function getTel100ModemProfile(pool: Pool, params: { coreDeviceId: number; user: AuthUser }) {
  const scope = coreDeviceScope(params.user);

  const whereParts: string[] = ["mp.core_device_id = ?", "d.deleted_at IS NULL"];
  const sqlParams: any[] = [params.coreDeviceId];

  if (scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    sqlParams.push(...scope.params);
  }

  const [rows] = await pool.query(
    `
  SELECT
    mp.core_device_id,
    mp.hamal_user,
    mp.job_title,
    mp.sim_black_ct, mp.sim_black_iv, mp.sim_black_tag, mp.sim_black_kv,
    mp.sim_red_binding_id_ct, mp.sim_red_binding_id_iv, mp.sim_red_binding_id_tag, mp.sim_red_binding_id_kv,
    mp.sim_red_copy_marking_short_ct, mp.sim_red_copy_marking_short_iv, mp.sim_red_copy_marking_short_tag, mp.sim_red_copy_marking_short_kv,
    mp.sim_red_copy_marking_long_ct, mp.sim_red_copy_marking_long_iv, mp.sim_red_copy_marking_long_tag, mp.sim_red_copy_marking_long_kv,
    mp.created_at,
    mp.updated_at
  FROM tel100_modem_profile mp
  JOIN core_device d ON d.id = mp.core_device_id
  LEFT JOIN storage_units u ON u.id = d.current_unit_id
  WHERE ${whereParts.join(" AND ")}
  LIMIT 1
  `,
    sqlParams
  );

  return (rows as any[])[0] || null;
}

export async function createTel100VoiceProfile(pool: Pool, params: { coreDeviceId: number; user: AuthUser }) {
  const scope = coreDeviceScope(params.user);

  const whereParts: string[] = ["d.id = ?", "d.deleted_at IS NULL"];
  const sqlParams: any[] = [params.coreDeviceId];

  if (scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    sqlParams.push(...scope.params);
  }

  // Scope enforcement: רק אם למשתמש מותר לראות/לגעת במכשיר הזה
  const [okRows] = await pool.query(
    `
    SELECT d.id
    FROM core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    `,
    sqlParams
  );
  if ((okRows as any[]).length === 0) return { created: false, reason: "FORBIDDEN_OR_NOT_FOUND" as const };

  // יצירה מינימלית (הטריגר יאכוף MAKAT)
  await pool.query(`INSERT INTO tel100_voice_profile (core_device_id) VALUES (?)`, [params.coreDeviceId]);
  return { created: true as const };
}

export async function createTel100ModemProfile(pool: Pool, params: { coreDeviceId: number; user: AuthUser }) {
  const scope = coreDeviceScope(params.user);

  const whereParts: string[] = ["d.id = ?", "d.deleted_at IS NULL"];
  const sqlParams: any[] = [params.coreDeviceId];

  if (scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    sqlParams.push(...scope.params);
  }

  const [okRows] = await pool.query(
    `
    SELECT d.id
    FROM core_device d
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    `,
    sqlParams
  );
  if ((okRows as any[]).length === 0) return { created: false, reason: "FORBIDDEN_OR_NOT_FOUND" as const };

  await pool.query(`INSERT INTO tel100_modem_profile (core_device_id) VALUES (?)`, [params.coreDeviceId]);
  return { created: true as const };
}

//
function addBundleUpdate(setParts: string[], setParams: any[], base: string, b: EncryptedBundle | null) {
  if (b === null) {
    setParts.push(`p.${base}_ct = NULL`, `p.${base}_iv = NULL`, `p.${base}_tag = NULL`, `p.${base}_kv = NULL`);
    return;
  }

  setParts.push(`p.${base}_ct = ?`, `p.${base}_iv = ?`, `p.${base}_tag = ?`, `p.${base}_kv = ?`);
  setParams.push(b.ct, b.iv, b.tag, b.kv);
}

export async function updateTel100ModemProfileQuery(
  pool: Pool,
  params: {
    coreDeviceId: number;
    hamalUser?: string | null;
    jobTitle?: string | null;

    simBlack?: EncryptedBundle | null;
    simRedBindingId?: EncryptedBundle | null;
    simRedCopyMarkingShort?: EncryptedBundle | null;
    simRedCopyMarkingLong?: EncryptedBundle | null;
  },
  user: AuthUser
) {
  const setParts: string[] = [];
  const setParams: any[] = [];

  if (params.hamalUser !== undefined) {
    setParts.push("p.hamal_user = ?");
    setParams.push(params.hamalUser);
  }

  if (params.jobTitle !== undefined) {
    setParts.push("p.job_title = ?");
    setParams.push(params.jobTitle);
  }

  if (params.simBlack !== undefined) addBundleUpdate(setParts, setParams, "sim_black", params.simBlack);
  if (params.simRedBindingId !== undefined) addBundleUpdate(setParts, setParams, "sim_red_binding_id", params.simRedBindingId);
  if (params.simRedCopyMarkingShort !== undefined) addBundleUpdate(setParts, setParams, "sim_red_copy_marking_short", params.simRedCopyMarkingShort);
  if (params.simRedCopyMarkingLong !== undefined) addBundleUpdate(setParts, setParams, "sim_red_copy_marking_long", params.simRedCopyMarkingLong);

  if (setParts.length === 0) {
    // nothing to update
    return { affectedRows: 0 } as ResultSetHeader;
  }

  const whereParts: string[] = ["p.core_device_id = ?", "d.deleted_at IS NULL"];
  const whereParams: any[] = [params.coreDeviceId];

  // NOTE: coreDeviceScope expects alias "u" to exist (storage_units)
  const scope = coreDeviceScope(user);
  if (scope?.clause && String(scope.clause).trim()) {
    whereParts.push(`(${scope.clause})`);
    whereParams.push(...(scope.params ?? []));
  }

  const sql = `
    UPDATE tel100_modem_profile p
    JOIN core_device d ON d.id = p.core_device_id
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    SET ${setParts.join(", ")}
    WHERE ${whereParts.join(" AND ")}
  `;

  const [r] = await pool.query<ResultSetHeader>(sql, [...setParams, ...whereParams]);
  return r;
}

export async function updateTel100VoiceProfileQuery(
  pool: Pool,
  params: {
    coreDeviceId: number;

    // non-encrypted
    fullName?: string | null;
    userType?: "PERMANENT" | "RESERVE" | "OTHER" | null;
    personalNumber?: string | null;
    jobTitle?: string | null;
    phoneNumber?: string | null;
    pttStatus?: "OK" | "NOT_OK" | "UNKNOWN" | null;

    // encrypted bundles
    pttGroup?: EncryptedBundle | null;
    hubPassword?: EncryptedBundle | null;
    operationalAuthCode?: EncryptedBundle | null;
    devicePin?: EncryptedBundle | null;
    openingTemplate?: EncryptedBundle | null;

    simBlack?: EncryptedBundle | null;
    simRedBindingId?: EncryptedBundle | null;
    simRedCopyMarkingShort?: EncryptedBundle | null;
    simRedCopyMarkingLong?: EncryptedBundle | null;
  },
  user: AuthUser
) {
  const setParts: string[] = [];
  const setParams: any[] = [];

  // helper: bundle -> 4 columns together
  const addBundle = (base: string, b: EncryptedBundle | null) => {
    if (b === null) {
      setParts.push(`p.${base}_ct = NULL`, `p.${base}_iv = NULL`, `p.${base}_tag = NULL`, `p.${base}_kv = NULL`);
      return;
    }
    setParts.push(`p.${base}_ct = ?`, `p.${base}_iv = ?`, `p.${base}_tag = ?`, `p.${base}_kv = ?`);
    setParams.push(b.ct, b.iv, b.tag, b.kv);
  };

  // non-encrypted
  if (params.fullName !== undefined) {
    setParts.push("p.full_name = ?");
    setParams.push(params.fullName);
  }
  if (params.userType !== undefined) {
    setParts.push("p.user_type = ?");
    setParams.push(params.userType);
  }
  if (params.personalNumber !== undefined) {
    setParts.push("p.personal_number = ?");
    setParams.push(params.personalNumber);
  }
  if (params.jobTitle !== undefined) {
    setParts.push("p.job_title = ?");
    setParams.push(params.jobTitle);
  }
  if (params.phoneNumber !== undefined) {
    setParts.push("p.phone_number = ?");
    setParams.push(params.phoneNumber);
  }
  if (params.pttStatus !== undefined) {
    setParts.push("p.ptt_status = ?");
    setParams.push(params.pttStatus);
  }

  // encrypted bundles (אם נשלח undefined -> לא נוגעים)
  if (params.pttGroup !== undefined) addBundle("ptt_group", params.pttGroup);
  if (params.hubPassword !== undefined) addBundle("hub_password", params.hubPassword);
  if (params.operationalAuthCode !== undefined) addBundle("operational_auth_code", params.operationalAuthCode);
  if (params.devicePin !== undefined) addBundle("device_pin", params.devicePin);
  if (params.openingTemplate !== undefined) addBundle("opening_template", params.openingTemplate);

  if (params.simBlack !== undefined) addBundle("sim_black", params.simBlack);
  if (params.simRedBindingId !== undefined) addBundle("sim_red_binding_id", params.simRedBindingId);
  if (params.simRedCopyMarkingShort !== undefined) addBundle("sim_red_copy_marking_short", params.simRedCopyMarkingShort);
  if (params.simRedCopyMarkingLong !== undefined) addBundle("sim_red_copy_marking_long", params.simRedCopyMarkingLong);

  if (setParts.length === 0) return;

  // scope (IMPORTANT: alias u exists)
  const whereParts: string[] = ["p.core_device_id = ?", "d.deleted_at IS NULL"];
  const whereParams: any[] = [params.coreDeviceId];

  const scope = coreDeviceScope(user); // { clause, params }
  if (scope.clause && scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    whereParams.push(...scope.params);
  }

  const sql = `
    UPDATE tel100_voice_profile p
    JOIN core_device d ON d.id = p.core_device_id
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    SET ${setParts.join(", ")}
    WHERE ${whereParts.join(" AND ")}
  `;

  const [r] = await pool.query<ResultSetHeader>(sql, [...setParams, ...whereParams]);
  return r;
}

export async function getTel100ModemProfileQuery(pool: Pool, coreDeviceId: number, user: AuthUser) {
  const whereParts: string[] = ["p.core_device_id = ?", "d.deleted_at IS NULL"];
  const whereParams: any[] = [coreDeviceId];

  const scope = coreDeviceScope(user); // { clause, params }
  if (scope.clause && scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    whereParams.push(...scope.params);
  }

  // const [rows] = await pool.query(`SELECT * FROM tel100_modem_profile WHERE core_device_id = ?`, [coreDeviceId]);
  const [rows] = await pool.query(
    `
    SELECT
    p.core_device_id,
    d.serial,
    d.device_name,
    d.makat,

    u.id AS current_unit_id,
    u.unit_name AS current_unit_name,
    u.storage_site AS current_storage_site,

    p.hamal_user,
    p.job_title,
    p.sim_black_ct, p.sim_black_iv, p.sim_black_tag, p.sim_black_kv,
    p.sim_red_binding_id_ct, p.sim_red_binding_id_iv, p.sim_red_binding_id_tag, p.sim_red_binding_id_kv,
    p.sim_red_copy_marking_short_ct, p.sim_red_copy_marking_short_iv, p.sim_red_copy_marking_short_tag, p.sim_red_copy_marking_short_kv,
    p.sim_red_copy_marking_long_ct, p.sim_red_copy_marking_long_iv, p.sim_red_copy_marking_long_tag, p.sim_red_copy_marking_long_kv,
    p.created_at,
    p.updated_at
    FROM tel100_modem_profile p
    JOIN core_device d ON d.id = p.core_device_id
    LEFT JOIN storage_units u ON u.id = d.current_unit_id
    WHERE ${whereParts.join(" AND ")}
    LIMIT 1
    `,
    whereParams
  );

  // if (!rows) return null;
  // return rows ?? null;
  return (rows as any[])[0] ?? null;
}
