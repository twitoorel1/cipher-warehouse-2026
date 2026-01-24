# PROJECT_CHECKLIST — Backend

## מצב נוכחי

- שלב: Backend Advanced
- מיקוד: יציבות, אבטחה, מוכנות לפרודקשן
- Frontend: ❌ לא התחיל

---

## Stage 1 — Foundations

- [x] Project structure
- [x] Env config
- [x] DB pool
- [x] Error handling
- [x] Logging

---

## Stage 2 — Auth & Security

- [x] Login
- [x] Refresh token
- [x] Logout
- [x] Origin guard
- [x] Rate limiting
- [ ] Threat model מתועד (⚠️ קיים בקוד בלבד)

---

## Stage 3 — RBAC & Permissions

- [x] Permission middleware
- [x] Permission overrides
- [ ] Scope enforcement audit מלא (⚠️ חלקי)

---

## Stage 4 — Core Domain (Devices)

- [x] Devices CRUD
- [x] Lookup by serial
- [ ] Lifecycle coverage מלא (⚠️ לבדיקה)

---

## Stage 5 — Imports (SAP)

- [x] Excel upload
- [ ] Idempotency מוחלט (⚠️ נדרש audit)
- [ ] Scheduler קבוע (❌)

---

## Stage 6 — TEL100

- [x] Voice profiles
- [x] Modem profiles
- [ ] Policy הצפנה והרשאות עקבי (⚠️)

---

## Stage 7 — Production Hardening

- [x] Health endpoint
- [ ] DB migrations
- [ ] Tests
- [ ] Docker
- [ ] CI baseline

---

## Definition of Done (Backend)

- [x] Write paths audited
- [ ] Security review
- [ ] No TODO in prod paths
- [ ] Ready for Frontend integration
