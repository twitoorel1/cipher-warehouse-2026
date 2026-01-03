export enum Roles {
  // ===== System level =====
  ADMIN = "ADMIN", // מנהל מערכת (בעל כל ההרשאות)

  // ===== Division level =====
  DIVISION_COMMANDER = "DIVISION_COMMANDER", // מפקד חטיבה
  DIVISION_DEPUTY_COMMANDER = "DIVISION_DEPUTY_COMMANDER", // סגן מפקד חטיבה

  // ===== Battalion level =====
  BATTALION_CHIEF_OFFICER = "BATTALION_CHIEF_OFFICER", // קצין ראשי
  BATTALION_DEPUTY_OFFICER = "BATTALION_DEPUTY_OFFICER", // קצין סגן
  BATTALION_NCO = "BATTALION_NCO", // נגד
  BATTALION_SOLDIER = "BATTALION_SOLDIER", // חייל
}

export type PermissionOverride = {
  permission: string; // אפשר להקשיח ל- Permissions enum בהמשך
  effect: "ALLOW" | "DENY";
};

export type AuthUser = {
  id: number;
  role: Roles;
  battalion_id: number | null;
  division_id: number | null;
  permissionOverrides: PermissionOverride[];
};

export interface LoginInput {
  username_or_email: string;
  password: string;
}
export interface MetaInfo {
  userAgent: string | null;
  ip: string | null;
}

export type IssueAccessTokenArgs = {
  userId: number;
  role: string;
  secret: string;
  ttlSeconds: number;

  battalionId: number | null;
  divisionId: number | null;
};

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
