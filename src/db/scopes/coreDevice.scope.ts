import { Roles } from "@/types/auth.js";
import type { AuthUser } from "@/types/auth.js";

export function coreDeviceScope(user: AuthUser): { clause: string; params: any[] } {
  if (user.role === Roles.ADMIN) {
    return { clause: "", params: [] };
  }

  if (user.role.startsWith("BATTALION_")) {
    if (!user.battalion_id) return { clause: "1=0", params: [] };
    // Scope by unit's battalion
    return { clause: "u.battalion_id = ?", params: [user.battalion_id] };
  }

  if (user.role.startsWith("DIVISION_")) {
    if (!user.division_id) return { clause: "1=0", params: [] };
    // Scope by division via battalions table
    return {
      clause: `
        u.division_id = ?
        OR EXISTS (
          SELECT 1
          FROM battalions b
          WHERE b.id = u.battalion_id
            AND b.division_id = ?
        )
      `,
      params: [user.division_id, user.division_id],
    };
  }

  return { clause: "1=0", params: [] };
}
