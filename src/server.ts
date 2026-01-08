import { createApp } from "./app.js";
import { loadEnv } from "./config/env.js";
import { createDbPool } from "./db/pool.js";

const env = loadEnv();
const pool = createDbPool(env);
const app = createApp(env, pool);

const server = app.listen(env.port, () => {
  console.log(`API running on http://localhost:${env.port}`);
});

let isShuttingDown = false;

async function shutdown(signal: string) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log(`Received ${signal}. Shutting down...`);

  // stop accepting new connections
  await new Promise<void>((resolve) => server.close(() => resolve()));

  // close DB pool (allow in-flight queries to finish)
  try {
    await Promise.race([pool.end(), new Promise((_, rej) => setTimeout(() => rej(new Error("DB_CLOSE_TIMEOUT")), 2000))]);
  } catch (e) {
    console.error("DB close error:", e);
  }

  process.exit(0);
}

process.on("SIGTERM", () => void shutdown("SIGTERM"));
process.on("SIGINT", () => void shutdown("SIGINT"));

process.on("unhandledRejection", (reason) => {
  console.error("UnhandledRejection:", reason);
  void shutdown("unhandledRejection");
});

process.on("uncaughtException", (err) => {
  console.error("UncaughtException:", err);
  void shutdown("uncaughtException");
});
