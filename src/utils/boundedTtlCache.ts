/**
 * Bounded TTL cache backed by Map (insertion order).
 *
 * Hardening goals:
 * - TTL per entry
 * - Max size cap
 * - Cleanup / eviction without background timers (opportunistic sweep)
 *
 * Implementation details:
 * - On `get`, we "touch" a key by re-inserting it to the end of the Map,
 *   approximating LRU eviction using Map iteration order.
 * - Expired keys are removed on access, and also during periodic sweeps.
 */

export type BoundedTtlCacheOptions = {
  /** Default TTL for entries (ms) */
  defaultTtlMs: number;
  /** Maximum number of entries allowed */
  maxSize: number;
  /** Minimum time between full sweeps (ms) */
  sweepIntervalMs: number;
};

type Entry<V> = {
  value: V;
  expiresAt: number; // epoch ms
};

export class BoundedTtlCache<K, V> {
  private readonly store = new Map<K, Entry<V>>();
  private lastSweepAt = 0;

  constructor(private readonly opts: BoundedTtlCacheOptions) {
    if (!Number.isFinite(opts.defaultTtlMs) || opts.defaultTtlMs <= 0) throw new Error("BoundedTtlCache: invalid defaultTtlMs");
    if (!Number.isFinite(opts.maxSize) || opts.maxSize <= 0) throw new Error("BoundedTtlCache: invalid maxSize");
    if (!Number.isFinite(opts.sweepIntervalMs) || opts.sweepIntervalMs < 0) throw new Error("BoundedTtlCache: invalid sweepIntervalMs");
  }

  size(): number {
    return this.store.size;
  }

  clear(): void {
    this.store.clear();
  }

  delete(key: K): boolean {
    return this.store.delete(key);
  }

  get(key: K, nowMs: number = Date.now()): V | undefined {
    const hit = this.store.get(key);
    if (!hit) {
      this.maybeSweep(nowMs);
      return undefined;
    }

    if (hit.expiresAt <= nowMs) {
      this.store.delete(key);
      this.maybeSweep(nowMs);
      return undefined;
    }

    // Touch for LRU-ish eviction
    this.store.delete(key);
    this.store.set(key, hit);

    this.maybeSweep(nowMs);
    return hit.value;
  }

  set(key: K, value: V, ttlMs?: number, nowMs: number = Date.now()): void {
    const effectiveTtl = typeof ttlMs === "number" && Number.isFinite(ttlMs) && ttlMs > 0 ? ttlMs : this.opts.defaultTtlMs;
    const expiresAt = nowMs + effectiveTtl;

    // Overwrite (and touch)
    this.store.delete(key);
    this.store.set(key, { value, expiresAt });

    this.maybeSweep(nowMs);
    this.evictIfNeeded();
  }

  private maybeSweep(nowMs: number) {
    if (this.opts.sweepIntervalMs === 0) return;
    if (nowMs - this.lastSweepAt < this.opts.sweepIntervalMs) return;
    this.lastSweepAt = nowMs;
    this.sweepExpired(nowMs);
  }

  private sweepExpired(nowMs: number) {
    // Iterate in insertion order; stop early is not safe because expirations may be non-monotonic.
    for (const [k, entry] of this.store) {
      if (entry.expiresAt <= nowMs) this.store.delete(k);
    }
  }

  private evictIfNeeded() {
    while (this.store.size > this.opts.maxSize) {
      // Oldest entry (Map preserves insertion order)
      const oldestKey = this.store.keys().next().value as K | undefined;
      if (oldestKey === undefined) break;
      this.store.delete(oldestKey);
    }
  }
}
