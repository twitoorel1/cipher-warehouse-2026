export type Keyring = {
  activeKv: number;
  keys: Map<number, Buffer>; // 32 bytes each
};

export function loadKeyringFromEnv(env: NodeJS.ProcessEnv): Keyring {
  const json = env.FIELD_CRYPTO_KEYS_JSON;
  const activeKvRaw = env.FIELD_CRYPTO_ACTIVE_KV;

  if (!json) throw new Error("Missing FIELD_CRYPTO_KEYS_JSON");
  if (!activeKvRaw) throw new Error("Missing FIELD_CRYPTO_ACTIVE_KV");

  const parsed = JSON.parse(json) as Record<string, string>;
  const keys = new Map<number, Buffer>();

  for (const [kvStr, b64] of Object.entries(parsed)) {
    const kv = Number(kvStr);
    if (!Number.isInteger(kv) || kv <= 0) throw new Error(`Invalid key version: ${kvStr}`);
    const buf = Buffer.from(b64, "base64");
    if (buf.length !== 32) throw new Error(`Key kv=${kv} must be 32 bytes (base64)`);
    keys.set(kv, buf);
  }

  const activeKv = Number(activeKvRaw);
  if (!keys.has(activeKv)) throw new Error(`Active kv=${activeKv} not found in FIELD_CRYPTO_KEYS_JSON`);

  return { activeKv, keys };
}
