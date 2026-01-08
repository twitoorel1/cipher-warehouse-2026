import { ROLE_PERMISSIONS } from "./rolePermissions.map.js";
import { Permissions } from "@/types/permissions.js";
import { Roles, type AuthUser } from "@/types/auth.js";

export type PermissionOverride = {
  permission: string;
  effect: "ALLOW" | "DENY";
};

function normPerm(p: unknown): string {
  return String(p ?? "").trim();
}

export function can(user: AuthUser & { permissionOverrides?: PermissionOverride[] }, permission: Permissions | string): boolean {
  const target = normPerm(permission);

  // Admin => always allowed
  if (user.role === Roles.ADMIN) return true;

  // 1) Overrides (DENY wins)
  const overrides = user.permissionOverrides ?? [];

  const hasDeny = overrides.some((o) => normPerm(o.permission) === target && o.effect === "DENY");
  if (hasDeny) return false;

  const hasAllow = overrides.some((o) => normPerm(o.permission) === target && o.effect === "ALLOW");
  if (hasAllow) return true;

  // 2) Role defaults
  const rolePerms = (ROLE_PERMISSIONS as any)[user.role] ?? [];
  return rolePerms.some((p: any) => normPerm(p) === target);
}
