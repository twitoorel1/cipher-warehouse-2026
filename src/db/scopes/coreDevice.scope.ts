import { Roles } from "../../types/auth.js";
import type { AuthUser } from "../../types/auth.js";

export function coreDeviceScope(user: AuthUser): { clause: string; params: any[] } {
  if (user.role === Roles.ADMIN) {
    return { clause: "", params: [] };
  }

  if (user.role.startsWith("BATTALION_")) {
    if (!user.battalion_id) return { clause: "1=0", params: [] };
    return { clause: "d.battalion_id = ?", params: [user.battalion_id] };
  }

  if (user.role.startsWith("DIVISION_")) {
    if (!user.division_id) return { clause: "1=0", params: [] };
    return {
      clause: `
        EXISTS (
          SELECT 1
          FROM battalions b
          WHERE b.id = d.battalion_id
            AND b.division_id = ?
        )
      `,
      params: [user.division_id],
    };
  }

  return { clause: "1=0", params: [] };
}
