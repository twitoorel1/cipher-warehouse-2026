import type { Pool } from "mysql2/promise";
import { coreDeviceScope } from "../scopes/coreDevice.scope.js";
import type { AuthUser } from "@/types/auth.js";

export async function getTel100VoiceProfile(pool: Pool, params: { coreDeviceId: number; user: AuthUser }) {
  const scope = coreDeviceScope(params.user);

  const whereParts: string[] = ["vp.core_device_id = ?", "d.deleted_at IS NULL"];
  const sqlParams: any[] = [params.coreDeviceId];

  if (scope.clause.trim()) {
    whereParts.push(`(${scope.clause})`);
    sqlParams.push(...scope.params);
  }

  const [rows] = await pool.query(
    `
  SELECT
    vp.core_device_id,
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
