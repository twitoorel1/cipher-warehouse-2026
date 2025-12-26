import type { Pool, PoolConnection, RowDataPacket, ResultSetHeader } from "mysql2/promise";

export type DbUser = {
  id: number;
  username: string;
  email: string;
  password_hash: string;
  role: string;
  is_active: number;
};

export async function findUserByUsernameOrEmail(db: Pool, value: string): Promise<DbUser | null> {
  const [rows] = await db.query<(DbUser & RowDataPacket)[]>(
    `
    SELECT id, username, email, password_hash, role, is_active
    FROM users
    WHERE username = ? OR email = ?
    LIMIT 1
    `,
    [value, value]
  );
  return rows[0] ?? null;
}

export async function findUserById(conn: PoolConnection, userId: number): Promise<Pick<DbUser, "id" | "role" | "is_active"> | null> {
  const [rows] = await conn.query<
    (RowDataPacket & {
      id: number;
      role: string;
      is_active: number;
    })[]
  >(
    `
    SELECT id, role, is_active
    FROM users
    WHERE id = ?
    LIMIT 1
    `,
    [userId]
  );
  return rows[0] ?? null;
}

export async function insertRefreshToken(
  conn: PoolConnection,
  args: {
    userId: number;
    tokenHashHex: string;
    issuedAt: Date;
    expiresAt: Date;
    userAgent: string | null;
    ip: string | null;
  }
): Promise<void> {
  await conn.execute<ResultSetHeader>(
    `
    INSERT INTO refresh_tokens
      (user_id, token_hash, issued_at, expires_at, revoked_at, user_agent, ip)
    VALUES (?, ?, ?, ?, NULL, ?, ?)
    `,
    [args.userId, args.tokenHashHex, args.issuedAt, args.expiresAt, args.userAgent, args.ip]
  );
}

export async function findActiveRefreshToken(conn: PoolConnection, tokenHashHex: string): Promise<{ id: number; user_id: number } | null> {
  const [rows] = await conn.query<
    (RowDataPacket & {
      id: number;
      user_id: number;
    })[]
  >(
    `
    SELECT id, user_id
    FROM refresh_tokens
    WHERE token_hash = ?
      AND revoked_at IS NULL
      AND expires_at > NOW()
    LIMIT 1
    `,
    [tokenHashHex]
  );
  return rows[0] ?? null;
}

export async function revokeRefreshToken(conn: PoolConnection, tokenHashHex: string): Promise<void> {
  await conn.execute<ResultSetHeader>(
    `
    UPDATE refresh_tokens
    SET revoked_at = NOW()
    WHERE token_hash = ?
      AND revoked_at IS NULL
    `,
    [tokenHashHex]
  );
}
