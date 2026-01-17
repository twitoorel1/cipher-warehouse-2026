import { z } from "zod";

export const tel100VoiceProfileUpsertSchema = z.object({
  core_device_id: z.number().int().positive(),

  full_name: z.string().max(160).nullable().optional(),
  user_type: z.enum(["PERMANENT", "RESERVE", "OTHER"]).nullable().optional(),
  personal_number: z.string().max(32).nullable().optional(),
  job_title: z.string().max(80).nullable().optional(),
  phone_number: z.string().max(32).nullable().optional(),
  ptt_status: z.enum(["OK", "NOT_OK", "UNKNOWN"]).optional(),

  // sensitive plaintext inputs (we encrypt in service)
  ptt_group: z.string().max(200).nullable().optional(),
  hub_password: z.string().max(200).nullable().optional(),
  operational_auth_code: z.string().max(200).nullable().optional(),
  device_pin: z.string().max(200).nullable().optional(),
  opening_template: z.string().max(500).nullable().optional(),
  sim_black: z.string().max(200).nullable().optional(),
  sim_red_binding_id: z.string().max(200).nullable().optional(),
  sim_red_copy_marking_short: z.string().max(200).nullable().optional(),
  sim_red_copy_marking_long: z.string().max(200).nullable().optional(),
});

export const modemPatchSchema = z.object({
  coreDeviceId: z.number().int().positive(),

  hamal_user: z.string().max(160).nullable().optional(),
  job_title: z.string().max(80).nullable().optional(),

  sim_black: z.string().max(128).nullable().optional(),
  sim_red_binding_id: z.string().max(128).nullable().optional(),
  sim_red_copy_marking_short: z.string().max(128).nullable().optional(),
  sim_red_copy_marking_long: z.string().max(128).nullable().optional(),
});
