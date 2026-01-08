// src/utils/writeRoutesAudit.ts
import type { Express } from "express";

type FoundRoute = {
  methods: string[];
  path: string;
  middlewareNames: string[];
};

function isWrite(method: string) {
  return ["post", "put", "patch", "delete"].includes(method.toLowerCase());
}

function joinPaths(base: string, add: string): string {
  const b = base.endsWith("/") ? base.slice(0, -1) : base;
  const a = add.startsWith("/") ? add : `/${add}`;
  return (b || "") + a;
}

/**
 * Express internals:
 * - app._router.stack contains layers
 * - router layers can be nested under layer.handle.stack
 * - mounted router "path" isn't directly exposed reliably; we infer it from layer.regexp when possible,
 *   but for stable behavior we accept approximate mount prefixes.
 */
function walkStack(stack: any[], basePath: string, out: FoundRoute[]) {
  for (const layer of stack) {
    // Route layer
    if (layer?.route) {
      const route = layer.route;
      const methods = Object.keys(route.methods || {}).filter((m) => route.methods[m]);
      if (!methods.some(isWrite)) continue;

      const middlewareNames = (route.stack || []).map((s: any) => s?.handle?.name).filter(Boolean);
      out.push({
        methods,
        path: joinPaths(basePath, route.path || "/"),
        middlewareNames,
      });
      continue;
    }

    // Nested router layer
    const handleStack = layer?.handle?.stack;
    if (Array.isArray(handleStack)) {
      // Best-effort mount path inference
      let mount = "";
      if (typeof layer?.path === "string") {
        mount = layer.path;
      } else if (layer?.regexp && layer.regexp.fast_slash) {
        mount = "";
      } else if (layer?.regexp && typeof layer.regexp.toString === "function") {
        // Example: /^\/auth\/?(?=\/|$)/i -> "/auth"
        const m = layer.regexp.toString().match(/\\\/([a-zA-Z0-9_-]+)\\\/\?\(\?=\\\/\|\$\)/);
        if (m?.[1]) mount = `/${m[1]}`;
      }

      walkStack(handleStack, joinPaths(basePath, mount || ""), out);
    }
  }
}

function collectRoutes(app: Express): FoundRoute[] {
  const anyApp = app as any;
  const stack = anyApp?._router?.stack ?? [];
  const out: FoundRoute[] = [];
  walkStack(stack, "", out);
  return out;
}

/**
 * Enforces:
 * - every WRITE route except /auth/* must include requirePermission
 */
export function auditWriteRoutes(app: Express) {
  const routes = collectRoutes(app);

  const violations = routes.filter((r) => {
    // allow auth writes to be public
    if (r.path.startsWith("/auth/")) return false;

    const hasRequirePermission = r.middlewareNames.some((n) => n.includes("requirePermission"));
    return !hasRequirePermission;
  });

  if (violations.length > 0) {
    const msg = "Write Routes Audit failed. Missing requirePermission on:\n" + violations.map((v) => `- [${v.methods.join(",").toUpperCase()}] ${v.path} (mw: ${v.middlewareNames.join(", ")})`).join("\n");
    throw new Error(msg);
  }
}
