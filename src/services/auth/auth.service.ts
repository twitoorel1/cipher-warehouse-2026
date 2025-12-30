import type { Pool } from "mysql2/promise";
import { withTransaction } from "../../db/tx.js";
import { AppError } from "../../middleware/error.middleware.js";
import { findUserByUsernameOrEmail, findUserById, insertRefreshToken, findActiveRefreshToken, revokeRefreshToken } from "../../db/queries/auth.queries.js";
import { verifyPassword } from "./password.service.js";
import { createRefreshToken, issueAccessToken, sha256Hex } from "./token.service.js";
import type { AppEnv } from "../../config/env.js";
import type { LoginInput, MetaInfo } from "../../types/auth.js";

export async function login(db: Pool, env: AppEnv, input: LoginInput, meta: MetaInfo): Promise<{ accessToken: string; refreshToken: string; userId: number; role: string }> {
  const user = await findUserByUsernameOrEmail(db, input.username_or_email);

  if (!user) throw new AppError({ code: "AUTH_INVALID_CREDENTIALS", status: 401, message: "Invalid credentials" });
  if (!user.is_active) throw new AppError({ code: "AUTH_USER_INACTIVE", status: 403, message: "User inactive" });

  const ok = await verifyPassword(input.password, user.password_hash);
  if (!ok) throw new AppError({ code: "AUTH_INVALID_CREDENTIALS", status: 401, message: "Invalid credentials" });

  const accessToken = await issueAccessToken({
    userId: user.id,
    role: user.role,
    battalionId: user.battalion_id ?? null,
    divisionId: user.division_id ?? null,
    secret: env.jwt.accessSecret,
    ttlSeconds: env.jwt.accessTtlSeconds,
  });

  const { token, tokenHashHex } = createRefreshToken();
  const issuedAt = new Date();
  const expiresAt = new Date(issuedAt.getTime() + env.jwt.refreshTtlDays * 86400000);

  // console.log(accessToken); // access token jwt // send to client in response body
  // console.log(token); // refresh token // send to client in cookie
  // console.log(tokenHashHex); // token hash in hex (save in mysql)

  await withTransaction(db, async (conn) => {
    await insertRefreshToken(conn, {
      userId: user.id,
      tokenHashHex,
      issuedAt,
      expiresAt,
      userAgent: meta.userAgent,
      ip: meta.ip,
    });
  });

  return { accessToken, refreshToken: token, userId: user.id, role: user.role };
}

export async function refresh(db: Pool, env: AppEnv, refreshToken: string | null, meta: { userAgent: string | null; ip: string | null }): Promise<{ accessToken: string; newRefreshToken: string; userId: number; role: string }> {
  if (!refreshToken) throw new AppError({ code: "AUTH_REFRESH_INVALID", status: 401, message: "Invalid refresh token" });

  const hash = sha256Hex(refreshToken);

  const result = await withTransaction(db, async (conn) => {
    const rt = await findActiveRefreshToken(conn, hash);
    if (!rt) throw new AppError({ code: "AUTH_REFRESH_INVALID", status: 401, message: "Invalid refresh token" });

    const user = await findUserById(conn, rt.user_id);
    if (!user || !user.is_active) throw new AppError({ code: "AUTH_USER_INACTIVE", status: 403, message: "User inactive" });

    await revokeRefreshToken(conn, hash);

    const { token, tokenHashHex } = createRefreshToken();
    const issuedAt = new Date();
    const expiresAt = new Date(issuedAt.getTime() + env.jwt.refreshTtlDays * 86400000);

    await insertRefreshToken(conn, {
      userId: user.id,
      tokenHashHex,
      issuedAt,
      expiresAt,
      userAgent: meta.userAgent,
      ip: meta.ip,
    });

    return { userId: user.id, role: user.role, newRefreshToken: token, battalionId: user.battalion_id ?? null, divisionId: user.division_id ?? null };
  });

  console.log(result);
  const accessToken = await issueAccessToken({
    userId: result.userId,
    role: result.role,
    battalionId: result.battalionId,
    divisionId: result.divisionId,
    secret: env.jwt.accessSecret,
    ttlSeconds: env.jwt.accessTtlSeconds,
  });

  return { accessToken, newRefreshToken: result.newRefreshToken, userId: result.userId, role: result.role };
}

export async function logout(db: Pool, refreshToken: string | null): Promise<{ msg: string } | undefined> {
  if (!refreshToken) return;

  const hash = sha256Hex(refreshToken);
  await withTransaction(db, async (conn) => {
    await revokeRefreshToken(conn, hash);
  });

  return { msg: "Logged out successfully" };
}
