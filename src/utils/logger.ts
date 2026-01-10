import type { Request } from "express";

/*
// log על ביצוע
export async function importDevices(...) {
  logger.info("import_devices_start", {
    userId,
    fileName,
    rowsCount,
  });

  // ... לוגיקה

  // Success
  logger.info("import_devices_success", {
    userId,
    imported: successCount,
    failed: failCount,
  });
}



| רמה     | מתי                       |
| ------- | ------------------------- |
| `debug` | דיבוג זמני / בעיה נקודתית |
| `info`  | אירוע עסקי משמעותי        |
| `warn`  | משהו לא תקין אבל לא שבר   |
| `error` | חריגה / משהו שדורש טיפול  |

*/

export type LogLevel = "debug" | "info" | "warn" | "error";

function nowIso() {
  return new Date().toISOString();
}

function isProd() {
  return process.env.NODE_ENV === "production";
}

const REDACT_KEYS = new Set(["authorization", "cookie", "set-cookie", "password", "token", "access_token", "accessToken", "refresh_token", "refreshToken", "secret"]);

function redact(obj: Record<string, unknown>) {
  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(obj)) {
    if (REDACT_KEYS.has(k.toLowerCase())) out[k] = "[REDACTED]";
    else out[k] = v;
  }
  return out;
}

export function log(level: LogLevel, msg: string, meta?: Record<string, unknown>) {
  const entry = {
    time: nowIso(),
    level,
    msg,
    ...(meta ? redact(meta) : {}),
  };

  // Keep stdout/stderr separation for container log collectors.
  const line = JSON.stringify(entry);
  if (level === "error") console.error(line);
  else if (level === "warn") console.warn(line);
  else console.log(line);
}

export function reqBaseMeta(req: Request) {
  const requestId = (req as any).requestId as string | undefined;
  const userId = req.user?.id;

  return {
    requestId,
    userId,
    method: req.method,
    path: req.path,
  };
}

export function safeErrorMeta(err: unknown) {
  if (err instanceof Error) {
    return {
      name: err.name,
      message: err.message,
      ...(isProd() ? {} : { stack: err.stack }),
    };
  }
  return { err };
}
