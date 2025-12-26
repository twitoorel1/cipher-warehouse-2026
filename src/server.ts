import { createApp } from "./app.js";
import { loadEnv } from "./config/env.js";
import { createDbPool } from "./db/pool.js";

const env = loadEnv();
const pool = createDbPool(env);

const app = createApp(env, pool);

app.listen(env.port, () => {
  console.log(`API running on http://localhost:${env.port}`);
});
