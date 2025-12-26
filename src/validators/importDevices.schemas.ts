import { z } from "zod";

export const storageSiteRegex = /^[A-Z]{2,4}\d{2,4}$/;

export const importInventoryRowSchema = z.object({
  serial: z
    .string()
    .min(1, "serial is required")
    .transform((s) => s.trim()),
  makat: z
    .string()
    .min(1, "makat is required")
    .transform((s) => s.trim()),
  device_name: z
    .string()
    .min(1, "device_name is required")
    .transform((s) => s.trim()),

  // Full raw text from Excel column "אתר אחסון"
  storage_unit_raw: z
    .string()
    .min(1, "storage_unit_raw is required")
    .transform((s) => s.trim()),

  // Extracted code like MG01 / VS02 / CX02 / MF71
  storage_site: z
    .string()
    .transform((s) => s.trim().toUpperCase())
    .refine((s) => storageSiteRegex.test(s), "storage_site must look like MG01 / VS02 / CX02 / MF71"),
});
export type ImportInventoryRow = z.infer<typeof importInventoryRowSchema>;

export const lifecycleStatusSchema = z.enum(["NEW", "PENDING_CARD", "ACTIVE", "NOT_ELIGIBLE", "TRANSFERRED", "REMOVED"]);
export type LifecycleStatus = z.infer<typeof lifecycleStatusSchema>;
