import { SignJWT } from "jose";
import crypto from "crypto";
import { IssueAccessTokenArgs } from "../../types/auth.js";

export async function issueAccessToken(args: IssueAccessTokenArgs): Promise<string> {
  const key = new TextEncoder().encode(args.secret);
  const now = Math.floor(Date.now() / 1000);

  return new SignJWT({ role: args.role })
    .setProtectedHeader({ alg: "HS256", typ: "JWT" })
    .setSubject(String(args.userId))
    .setIssuedAt(now)
    .setExpirationTime(now + args.ttlSeconds)
    .sign(key);
}

export function createRefreshToken(): { token: string; tokenHashHex: string } {
  const raw = crypto.randomBytes(48).toString("base64url");
  const hash = crypto.createHash("sha256").update(raw).digest("hex");
  return { token: raw, tokenHashHex: hash };
}

export function sha256Hex(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}
