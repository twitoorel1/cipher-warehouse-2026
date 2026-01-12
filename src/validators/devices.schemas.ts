import { z } from "zod";

export const devicesListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(200).default(50),
  sort_by: z.enum(["updated_at", "created_at", "device_name", "makat", "serial"]).default("updated_at"),
  sort_order: z.enum(["asc", "desc"]).default("desc"),
  search: z.string().trim().min(1).max(191).optional(),
  lifecycle_status: z.enum(["NEW", "PENDING_CARD", "ACTIVE", "NOT_ELIGIBLE", "TRANSFERRED", "REMOVED"]).optional(),
  device_name: z.string().trim().min(1).max(191).optional(),
  storage_site: z.string().trim().min(1).max(191).optional(),
  battery_life: z.string().trim().min(7).max(7).optional(),
});

export type DevicesListQuery = z.infer<typeof devicesListQuerySchema>;

export const deviceIdParamSchema = z.object({
  id: z.coerce.number().int().min(1),
});

export type DeviceIdParam = z.infer<typeof deviceIdParamSchema>;

// PATCH schema for updating a device (partial update)
// Business rules:
// - serial and current_unit_id are intentionally NOT allowed here (serial restricted; unit controlled via import)
// - battery_life is provided as MM/YYYY and stored as DATE (YYYY-MM-01)
const mmYYYY = /^\d{2}\/\d{4}$/; // example: 08/2025

export const devicePatchSchema = z
  .object({
    makat: z.string().trim().min(1).max(64).optional(),
    device_name: z.string().trim().min(1).max(255).optional(),
    encryption_model_id: z.coerce.number().int().min(1).nullable().optional(),
    battery_life: z.union([z.string().trim().regex(mmYYYY, "battery_life must be in MM/YYYY"), z.null()]).optional(),
    lifecycle_status: z.enum(["NEW", "PENDING_CARD", "ACTIVE", "NOT_ELIGIBLE", "TRANSFERRED", "REMOVED"]).optional(),
  })
  .strict()
  .refine((o) => Object.keys(o).length > 0, { message: "At least one field is required" });

export type DevicePatchBody = z.infer<typeof devicePatchSchema>;
