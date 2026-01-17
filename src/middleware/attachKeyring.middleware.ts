import type { Request, Response, NextFunction } from "express";
import type { Keyring } from "../crypto/keyring.js";

export function attachKeyring(_req: Request, _res: Response, next: NextFunction) {
  // הערך יושב ב-app.locals, נצמיד אותו ל-req
  // חשוב: משתמשים ב-(req as any) כאן רק כי Express typings לא תמיד מכירים locals
  next();
}

export function attachKeyringFromLocals(req: Request, _res: Response, next: NextFunction) {
  const keyring = (req.app as any).locals?.keyring as Keyring | undefined;
  if (!keyring) {
    return next(new Error("Keyring is not configured (app.locals.keyring missing)"));
  }
  req.keyring = keyring;
  next();
}
