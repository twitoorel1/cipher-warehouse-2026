import type { Request, Response, NextFunction } from "express";
import crypto from "crypto";

export function requestContext() {
  return (req: Request, res: Response, next: NextFunction) => {
    const requestId = crypto.randomUUID();
    (req as any).requestId = requestId;
    res.setHeader("x-request-id", requestId);
    next();
  };
}
