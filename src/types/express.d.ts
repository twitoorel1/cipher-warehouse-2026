import "express";
import { Roles } from "../types/auth";

declare module "express-serve-static-core" {
  interface Request {
    user?: {
      id: number;
      role: Roles;
      battalion_id: number | null;
      division_id: number | null;
      permissionOverrides: PermissionOverride[];
    };
  }
}
