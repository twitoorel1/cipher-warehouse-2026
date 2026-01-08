import type { Pool, RowDataPacket } from "mysql2/promise";

export type PermissionOverrideEffect = "ALLOW" | "DENY";

export type PermissionOverride = {
  permission: string;
  effect: PermissionOverrideEffect;
};

type CacheEntry = {
  overrides: PermissionOverride[];
  expiresAt: number; // epoch ms
};

const cache = new Map<number, CacheEntry>();
const DEFAULT_TTL_MS = 60_000;

function nowMs() {
  return Date.now();
}

export function clearPermissionOverridesCache(userId?: number) {
  if (typeof userId === "number") cache.delete(userId);
  else cache.clear();
}

async function loadOverridesFromDb(pool: Pool, userId: number): Promise<PermissionOverride[]> {
  const [rows] = await pool.query<(RowDataPacket & { permission: string; effect: PermissionOverrideEffect })[]>(
    `
    SELECT permission, effect
    FROM user_permission_overrides
    WHERE user_id = ?
    `,
    [userId]
  );

  // ניקוי בסיסי + de-dup הגנתי
  const map = new Map<string, PermissionOverrideEffect>();
  for (const r of rows) {
    if (!r?.permission) continue;
    if (r.effect !== "ALLOW" && r.effect !== "DENY") continue;
    map.set(r.permission, r.effect);
  }

  return Array.from(map.entries()).map(([permission, effect]) => ({ permission, effect }));
}

export async function loadPermissionOverridesCached(pool: Pool, userId: number, ttlMs: number = DEFAULT_TTL_MS): Promise<PermissionOverride[]> {
  const hit = cache.get(userId);
  const t = nowMs();

  if (hit && hit.expiresAt > t) return hit.overrides;

  const overrides = await loadOverridesFromDb(pool, userId);

  cache.set(userId, {
    overrides,
    expiresAt: t + ttlMs,
  });

  return overrides;
}
