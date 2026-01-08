import { z } from "zod";

export const storageSiteRegex = /^[A-Z]{2,4}\d{2,4}$/;

export const importInventoryRowSchema = z.object({
  serial: z.string().trim().min(1).max(64),
  makat: z.string().trim().min(1).max(64),
  device_name: z.string().trim().min(1).max(255),
  storage_unit_raw: z.string().trim().min(1).max(255),
  storage_site: z.string().trim().toUpperCase().regex(storageSiteRegex, "Invalid storage_site"),
});

export type ImportInventoryRow = z.infer<typeof importInventoryRowSchema>;

export const lifecycleStatusSchema = z.enum(["NEW", "PENDING_CARD", "ACTIVE", "NOT_ELIGIBLE", "TRANSFERRED", "REMOVED"]);
export type LifecycleStatus = z.infer<typeof lifecycleStatusSchema>;
