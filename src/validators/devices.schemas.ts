import { z } from "zod";

export const devicesListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(200).default(50),
  sort_by: z.enum(["updated_at", "created_at", "device_name", "makat", "serial"]).default("updated_at"),
  sort_order: z.enum(["asc", "desc"]).default("desc"),
  search: z.string().trim().min(1).max(191).optional(),
  lifecycle_status: z.enum(["NEW", "PENDING_CARD", "ACTIVE", "NOT_ELIGIBLE", "TRANSFERRED", "REMOVED"]).optional(),
});

export type DevicesListQuery = z.infer<typeof devicesListQuerySchema>;

export const deviceIdParamSchema = z.object({
  id: z.coerce.number().int().min(1),
});

export type DeviceIdParam = z.infer<typeof deviceIdParamSchema>;
