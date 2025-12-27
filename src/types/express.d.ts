import "express";
import { Roles } from "../types/auth";

declare module "express-serve-static-core" {
  interface Request {
    user?: {
      id: number;
      premissions?: string[];
      role: Roles;
    };
  }
}
