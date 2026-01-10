import type { Pool, RowDataPacket } from "mysql2/promise";
import { BoundedTtlCache } from "@/utils/boundedTtlCache.js";

export type PermissionOverrideEffect = "ALLOW" | "DENY";

export type PermissionOverride = {
  permission: string;
  effect: PermissionOverrideEffect;
};

/**
 * In-memory cache hardening:
 * - TTL per user
 * - Bounded size cap to prevent unbounded growth
 * - Opportunistic sweeps on access (no background timers)
 */
const DEFAULT_TTL_MS = 60_000;
const MAX_USERS_CACHED = 10_000;
const SWEEP_INTERVAL_MS = 30_000;

const cache = new BoundedTtlCache<number, PermissionOverride[]>({
  defaultTtlMs: DEFAULT_TTL_MS,
  maxSize: MAX_USERS_CACHED,
  sweepIntervalMs: SWEEP_INTERVAL_MS,
});

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
  const t = nowMs();
  const hit = cache.get(userId, t);
  if (hit) return hit;

  const overrides = await loadOverridesFromDb(pool, userId);
  cache.set(userId, overrides, ttlMs, t);
  return overrides;
}
