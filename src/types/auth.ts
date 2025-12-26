export enum Roles {
  ADMIN = "ADMIN",
  EDITOR = "EDITOR",
  VIEWER = "VIEWER",
}

export type AuthUser = {
  id: number;
  role: Roles;
};

export interface LoginInput {
  username_or_email: string;
  password: string;
}
export interface MetaInfo {
  userAgent: string | null;
  ip: string | null;
}

export interface IssueAccessTokenArgs {
  userId: number;
  role: string;
  secret: string;
  ttlSeconds: number;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
