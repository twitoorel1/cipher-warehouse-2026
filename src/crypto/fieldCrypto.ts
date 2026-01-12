import crypto from "node:crypto";
import type { Keyring } from "./keyring.js";

export type EncryptedBundle = {
  ct: Buffer;
  iv: Buffer; // 12 bytes
  tag: Buffer; // 16 bytes
  kv: number;
};

const IV_LEN = 12;
const TAG_LEN = 16;

export function encryptUtf8(keyring: Keyring, plaintext: string, aad?: string): EncryptedBundle {
  const kv = keyring.activeKv;
  const key = keyring.keys.get(kv);
  if (!key) throw new Error(`Missing key for kv=${kv}`);

  const iv = crypto.randomBytes(IV_LEN);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);

  if (aad) cipher.setAAD(Buffer.from(aad, "utf8"));

  const ct = Buffer.concat([cipher.update(Buffer.from(plaintext, "utf8")), cipher.final()]);
  const tag = cipher.getAuthTag();
  if (tag.length !== TAG_LEN) throw new Error("Unexpected GCM tag length");

  return { ct, iv, tag, kv };
}

export function decryptUtf8(keyring: Keyring, bundle: EncryptedBundle, aad?: string): string {
  const key = keyring.keys.get(bundle.kv);
  if (!key) throw new Error(`Missing key for kv=${bundle.kv}`);

  const decipher = crypto.createDecipheriv("aes-256-gcm", key, bundle.iv);
  if (aad) decipher.setAAD(Buffer.from(aad, "utf8"));
  decipher.setAuthTag(bundle.tag);

  const pt = Buffer.concat([decipher.update(bundle.ct), decipher.final()]);
  return pt.toString("utf8");
}
