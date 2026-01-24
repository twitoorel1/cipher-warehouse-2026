# PROJECT_OVERVIEW — Backend (AS-IS)

## 1) מטרת הפרויקט (Why)

מערכת Backend לניהול מחסן מכשירי הצפנה ותקשורת.
המערכת מאפשרת:

- ניהול כרטיס מכשיר לפי מק"ט + מספר סיריאלי
- קליטת נתונים מ־SAP (ייבוא אקסלים)
- קביעת כשירות / אי־כשירות של מכשירים
- ניהול פרופילי TEL100 (דיבור / מודם)
- אכיפת הרשאות (RBAC) ו־Audit

המערכת היא מקור אמת (Source of Truth) למצב מכשיר במחסן.

---

## 2) Stack (Backend בלבד)

- Runtime: Node.js
- Language: TypeScript
- Framework: Express
- DB: MySQL 8
- Auth: JWT (Access + Refresh Tokens)
- RBAC: Permissions + Overrides
- Validation: Zod
- Crypto: AES-GCM Field Encryption (Keyring)
- Logging: Request Context + Access Log + Audit
- API Style: REST

Frontend: ❌ לא קיים עדיין (לא חלק מהשלב הנוכחי)

---

## 3) ארכיטקטורה (High-Level)

### Entry Points

- `src/server.ts`
- `src/app.ts`

### Layers (Non-Negotiable)

- routes
- controllers (Orchestration בלבד)
- services (Business Logic)
- db
  - queries
  - scopes
  - transactions
- middleware
- crypto
- utils

אין לוגיקה עסקית ב־controllers.

---

## 4) DB Model (Core Entities)

### ישויות מרכזיות

- `core_device`
  - serial (UNIQUE)
  - makat
  - status / lifecycle
  - storage_unit
  - encryption_model
- `users`
- `refresh_tokens`
- `user_permission_overrides`
- `divisions`
- `battalions`
- `storage_units`

### הצפנה

- `encryption_device_model`
- `encryption_family`
- `encryption_period`
- `encryption_unit_symbol`
- `encryption_family_rule`

### TEL100

- `tel100_voice_profile`
- `tel100_modem_profile`

---

## 5) Security Model (AS-IS)

- JWT Access Tokens
- Refresh Tokens עם טבלת `refresh_tokens`
- Origin Guard ל־refresh/logout
- RBAC:
  - Permissions
  - Permission Overrides
- אכיפת הרשאות ב־middleware
- Field-level encryption:
  - Keyring
  - KV rotation

---

## 6) Utilities / Helpers

- Logging & request context
- Audit write paths
- Device type resolution לפי מק"ט
- Date / formatting utilities
- Excel parsing + validation

---

## 7) Folder Structure (Backend)

- src/
  - app.ts
  - server.ts
  - routes/
  - controllers/
  - services/
  - db/
    - pool
    - queries
    - scopes
  - middleware/
  - crypto/
  - utils/
  - types/
  - config/

---

## 8) החלטות קיימות (AS-IS)

### הוחלט

- חלוקה לשכבות ברורה
- serial הוא מזהה ייחודי
- אין Write בלי Permission
- הצפנת שדות רגישים

### אסור לשנות

- מבנה שכבות
- לוגיקת הרשאות
- משמעות serial כמזהה

---

## 9) TODOs ברמה גבוהה (Backend)

- Write Paths Audit מלא
- Idempotency מלא לייבוא SAP
- Migrations (במקום SQL dump)
- Tests (יחידה / אינטגרציה)
- Docker + CI בסיסי
- OpenAPI / Swagger (אופציונלי)

---

## 10) שלב נוכחי

Backend מתקדם — לפני Production Hardening ולפני Frontend.
