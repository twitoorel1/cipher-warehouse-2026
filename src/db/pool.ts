import mysql from "mysql2/promise";
import type { Pool } from "mysql2/promise";
// import type { AppEnv } from "../config/env";
import type { AppEnv } from "../config/env.js";

export function createDbPool(env: AppEnv): Pool {
  return mysql.createPool({
    host: env.db.host,
    port: env.db.port,
    user: env.db.user,
    password: env.db.password,
    database: env.db.name,
    waitForConnections: true,
    connectionLimit: env.db.connLimit,
    queueLimit: 0,
  });
}
