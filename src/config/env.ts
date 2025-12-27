import fs from "fs";
import path from "path";

function parseDotEnv(content: string): Record<string, string> {
  const out: Record<string, string> = {};
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;
    if (line.startsWith("#")) continue;

    const eq = line.indexOf("=");
    if (eq === -1) continue;

    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();

    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    } else {
      const hash = value.indexOf("#");
      if (hash !== -1) value = value.slice(0, hash).trim();
    }

    if (key) out[key] = value;
  }
  return out;
}

function loadDotEnvFile(): void {
  const envPath = path.resolve(process.cwd(), ".env");
  if (!fs.existsSync(envPath)) return;

  const content = fs.readFileSync(envPath, "utf8");
  const parsed = parseDotEnv(content);

  for (const [k, v] of Object.entries(parsed)) {
    if (process.env[k] === undefined) process.env[k] = v;
  }
}

export type AppEnv = {
  port: number;
  corsOrigins: string[];
  db: {
    host: string;
    port: number;
    user: string;
    password: string;
    name: string;
    connLimit: number;
  };
  jwt: {
    accessSecret: string;
    accessTtlSeconds: number;
    refreshTtlDays: number;
    issuer?: string;
    audience?: string;
  };
};

export function loadEnv(): AppEnv {
  loadDotEnvFile();

  const portRaw = process.env.PORT ?? "4000";
  const port = Number(portRaw);

  const corsRaw = process.env.CORS_ORIGINS ?? "http://localhost:3000";
  const corsOrigins = corsRaw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);

  const dbHost = process.env.DB_HOST ?? "localhost";
  const dbPortRaw = process.env.DB_PORT ?? "3306";
  const dbPort = Number(dbPortRaw);

  const dbUser = process.env.DB_USER ?? "";
  const dbPassword = process.env.DB_PASSWORD ?? "";
  const dbName = process.env.DB_NAME ?? "";

  const dbConnLimitRaw = process.env.DB_CONN_LIMIT ?? "10";
  const dbConnLimit = Number(dbConnLimitRaw);

  const jwtAccessSecret = process.env.JWT_ACCESS_SECRET ?? "";
  const jwtAccessTtlRaw = process.env.JWT_ACCESS_TTL_SECONDS ?? "900";
  const jwtAccessTtlSeconds = Number(jwtAccessTtlRaw);

  const refreshTtlRaw = process.env.REFRESH_TOKEN_TTL_DAYS ?? "30";
  const refreshTtlDays = Number(refreshTtlRaw);

  if (!Number.isFinite(port) || port <= 0) throw new Error("Invalid PORT");
  if (corsOrigins.length === 0) throw new Error("Invalid CORS_ORIGINS");

  if (!Number.isFinite(dbPort) || dbPort <= 0) throw new Error("Invalid DB_PORT");
  if (!Number.isFinite(dbConnLimit) || dbConnLimit <= 0) throw new Error("Invalid DB_CONN_LIMIT");
  if (!dbUser) throw new Error("Missing DB_USER");
  if (!dbName) throw new Error("Missing DB_NAME");

  if (!jwtAccessSecret) throw new Error("Missing JWT_ACCESS_SECRET");
  if (!Number.isFinite(jwtAccessTtlSeconds) || jwtAccessTtlSeconds <= 0) throw new Error("Invalid JWT_ACCESS_TTL_SECONDS");
  if (!Number.isFinite(refreshTtlDays) || refreshTtlDays <= 0) throw new Error("Invalid REFRESH_TOKEN_TTL_DAYS");

  return {
    port,
    corsOrigins,
    db: {
      host: dbHost,
      port: dbPort,
      user: dbUser,
      password: dbPassword,
      name: dbName,
      connLimit: dbConnLimit,
    },
    jwt: {
      accessSecret: jwtAccessSecret,
      accessTtlSeconds: jwtAccessTtlSeconds,
      refreshTtlDays: refreshTtlDays,
    },
  };
}
