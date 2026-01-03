import type { Request, Response, NextFunction } from "express";
import { can } from "@/rbac/can.js";
import { Permissions } from "@/types/permissions.js";

export function requirePermission(permission: Permissions) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) {
      return res.status(401).json({ message: "Unauthorized", code: 4 });
    }

    if (!can(user, permission)) {
      return res.status(403).json({ message: "Forbidden: Insufficient permissions" });
    }

    next();
  };
}
