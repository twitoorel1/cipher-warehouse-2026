import type { Pool, PoolConnection } from "mysql2/promise";

export async function withTransaction<T>(pool: Pool, fn: (conn: PoolConnection) => Promise<T>): Promise<T> {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const result = await fn(conn);
    await conn.commit();
    return result;
  } catch (error: any) {
    try {
      await conn.rollback();
    } catch (error: any) {}
    throw error;
  } finally {
    conn.release();
  }
}
