import type { Pool, RowDataPacket } from "mysql2/promise";

export type UserPermissionOverrideRow = RowDataPacket & {
  permission: string;
  effect: "ALLOW" | "DENY";
};

export async function listUserPermissionOverrides(pool: Pool, userId: number): Promise<UserPermissionOverrideRow[]> {
  const [rows] = await pool.query<UserPermissionOverrideRow[]>(
    `
    SELECT permission, effect
    FROM user_permission_overrides
    WHERE user_id = ?
    `,
    [userId]
  );

  return rows;
}
