import { Roles } from "@/types/auth.js";
import { Permissions } from "@/types/permissions.js";

// Default permissions assigned to each role
export const ROLE_PERMISSIONS: Record<Roles, Permissions[]> = {
  // =========================
  // Battalion
  // =========================
  [Roles.BATTALION_SOLDIER]: [Permissions.DEVICES_READ, Permissions.INVENTORY_READ],

  [Roles.BATTALION_NCO]: [Permissions.DEVICES_READ, Permissions.DEVICES_UPDATE, Permissions.INVENTORY_READ],

  [Roles.BATTALION_DEPUTY_OFFICER]: [Permissions.DEVICES_READ, Permissions.DEVICES_UPDATE, Permissions.DEVICES_IMPORT, Permissions.INVENTORY_READ, Permissions.INVENTORY_COUNT_APPROVE],

  [Roles.BATTALION_CHIEF_OFFICER]: [
    Permissions.DEVICES_READ,
    Permissions.DEVICES_CREATE,
    Permissions.DEVICES_UPDATE,
    Permissions.DEVICES_DELETE,
    Permissions.DEVICES_IMPORT,
    Permissions.DEVICES_EXPORT,
    Permissions.INVENTORY_READ,
    Permissions.INVENTORY_COUNT_APPROVE,
    Permissions.INVENTORY_ADJUST,
  ],

  // =========================
  // Division
  // =========================
  [Roles.DIVISION_COMMANDER]: [
    Permissions.DEVICES_READ,
    Permissions.DEVICES_CREATE,
    Permissions.DEVICES_UPDATE,
    Permissions.DEVICES_DELETE,
    Permissions.DEVICES_IMPORT,
    Permissions.DEVICES_EXPORT,
    Permissions.INVENTORY_READ,
    Permissions.INVENTORY_COUNT_APPROVE,
    Permissions.INVENTORY_ADJUST,
    Permissions.UNITS_READ,
    Permissions.BATTALIONS_READ,
  ],

  [Roles.DIVISION_DEPUTY_COMMANDER]: [Permissions.DEVICES_READ, Permissions.DEVICES_UPDATE, Permissions.DEVICES_IMPORT, Permissions.INVENTORY_READ, Permissions.INVENTORY_COUNT_APPROVE, Permissions.UNITS_READ],

  // =========================
  // Admin
  // =========================
  [Roles.ADMIN]: Object.values(Permissions),
};
