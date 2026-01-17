import { createApp } from "./app.js";
import { loadEnv } from "./config/env.js";
import { createDbPool } from "./db/pool.js";
import { log } from "./utils/logger.js";
import { loadKeyringFromEnv } from "./crypto/keyring.js";

const env = loadEnv();
const pool = createDbPool(env);

const keyring = loadKeyringFromEnv(process.env);

const app = createApp(env, pool);
(app as any).locals.keyring = keyring;

const server = app.listen(env.port, () => {
  log("info", "server_listening", {
    port: env.port,
    node: process.version,
    pid: process.pid,
    env: process.env.NODE_ENV || "development",
  });
});

// Lightweight process metrics to catch memory growth in production.
// Controlled by env var to avoid noise in local dev.
const metricsIntervalSeconds = Number(process.env.METRICS_LOG_INTERVAL_SECONDS ?? (process.env.NODE_ENV === "production" ? "300" : "0"));
if (Number.isFinite(metricsIntervalSeconds) && metricsIntervalSeconds > 0) {
  setInterval(() => {
    const m = process.memoryUsage();
    log("info", "process_metrics", {
      rss: m.rss,
      heapUsed: m.heapUsed,
      heapTotal: m.heapTotal,
      external: m.external,
      uptimeSeconds: Math.floor(process.uptime()),
    });
  }, metricsIntervalSeconds * 1000).unref();
}

let isShuttingDown = false;

async function shutdown(signal: string) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  log("warn", "shutdown_start", { signal });

  // stop accepting new connections
  await new Promise<void>((resolve) => server.close(() => resolve()));

  // close DB pool (allow in-flight queries to finish)
  try {
    await Promise.race([pool.end(), new Promise((_, rej) => setTimeout(() => rej(new Error("DB_CLOSE_TIMEOUT")), 2000))]);
  } catch (e) {
    log("error", "db_close_error", { err: e instanceof Error ? e.message : String(e) });
  }

  process.exit(0);
}

process.on("SIGTERM", () => void shutdown("SIGTERM"));
process.on("SIGINT", () => void shutdown("SIGINT"));

process.on("unhandledRejection", (reason) => {
  log("error", "unhandled_rejection", { reason: reason instanceof Error ? reason.message : String(reason) });
  void shutdown("unhandledRejection");
});

process.on("uncaughtException", (err) => {
  log("error", "uncaught_exception", { err: err.message });
  void shutdown("uncaughtException");
});
