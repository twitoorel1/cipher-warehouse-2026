import { SignJWT } from "jose";
import crypto from "crypto";
import { IssueAccessTokenArgs } from "../../types/auth.js";

export async function issueAccessToken(args: IssueAccessTokenArgs & { issuer?: string; audience?: string }): Promise<string> {
  const key = new TextEncoder().encode(args.secret);
  const now = Math.floor(Date.now() / 1000);

  let jwt = new SignJWT({
    role: args.role,
    battalion_id: args.battalionId,
    division_id: args.divisionId,
  })
    .setProtectedHeader({ alg: "HS256", typ: "JWT" })
    .setSubject(String(args.userId))
    .setIssuedAt(now)
    .setExpirationTime(now + args.ttlSeconds);

  if (args.issuer) jwt = jwt.setIssuer(args.issuer);
  if (args.audience) jwt = jwt.setAudience(args.audience);

  return jwt.sign(key);
}

export function createRefreshToken(): { token: string; tokenHashHex: string } {
  const raw = crypto.randomBytes(48).toString("base64url");
  const hash = crypto.createHash("sha256").update(raw).digest("hex");
  return { token: raw, tokenHashHex: hash };
}

export function sha256Hex(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}
