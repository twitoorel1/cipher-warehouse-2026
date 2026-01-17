import "express";
import { Roles, PermissionOverride } from "../types/auth";
import { Keyring } from "@/crypto/keyring.ts";
import { AuthUser } from "./auth.ts";

declare module "express-serve-static-core" {
  interface Request {
    user?: {
      id: number;
      role: Roles;
      battalion_id: number | null;
      division_id: number | null;
      permissionOverrides: PermissionOverride[];
    };
    keyring?: Keyring;
    requestId?: string;
  }
}

// declare module "express-serve-static-core" {
//   interface Request {
//     user?: AuthUser;
//     keyring: Keyring;
//     requestId?: string;
//   }
// }
