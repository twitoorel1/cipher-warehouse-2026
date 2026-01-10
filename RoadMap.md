# Production Hardening Roadmap

## Cipher Warehouse – Backend (Node.js / TypeScript / MySQL)

מטרת מסמך זה היא להגדיר **מפת דרכים מסודרת וברורה** להקשחת המערכת לקראת סביבת Production,  
באופן מדורג, מבוקר, וללא ניחושים.

---

## 🎯 מטרה סופית

מערכת Backend ש:

- יציבה לאורך זמן (שבועות / חודשים)
- בטוחה לשימוש בפרודקשן
- ניתנת לתחקור ותחזוקה
- לא קורסת בגלל זיכרון / הרשאות / לוגים
- עומדת בסטנדרט Best Practice (לא Demo)

---

## שלב 1 – אבטחה בסיסית (Security Fundamentals) ✅

**סטטוס: הושלם**

### מה בוצע

- הגנת CSRF מינימלית על Refresh / Logout
- טיפול נכון ב־Origin / Referer
- תמיכה מלאה בעבודה עם:
  - דפדפן
  - Postman / curl (Development)
- Cookies עם:
  - `HttpOnly`
  - `SameSite=Strict`
  - `Secure` בפרודקשן
- מניעת דליפת `details` רגישים בשגיאות בפרודקשן

### סיכונים שטופלו

- CSRF
- שימוש זדוני ב־Refresh Token
- שבירת עבודה בסביבת Dev

---

## שלב 2 – יציבות זיכרון (Memory & Cache Hardening) ⏭️

**סטטוס: בתהליך**

### מטרות

- למנוע גדילה בלתי מבוקרת של זיכרון
- למנוע תקלות שמופיעות רק אחרי זמן

### משימות

- החלפת `Map` פשוט ב־Cache עם:
  - TTL (Time To Live)
  - Max Size (Cap)
  - Cleanup תקופתי
- מימוש LRU או eviction פשוט
- חיבור invalidate ל:
  - שינוי הרשאות
  - שינוי roles
  - שינוי permission overrides

### רכיבים מושפעים

- Permission Overrides Cache
- RBAC Services
- Authorization Layer

---

## שלב 3 – Logging & Observability ⏭️

**סטטוס: מתוכנן**

### מטרות

- יכולת תחקור תקלות בפרודקשן
- זיהוי מהיר של בקשות בעייתיות

### משימות

- הוספת `requestId`:
  - מכותרת (`x-request-id`) אם קיימת
  - יצירה אוטומטית אם לא
- החזרת `requestId` ב־Response Headers
- לוגים עקביים:
  - method
  - path
  - status
  - requestId
- לוג שגיאות נקי (ללא דליפת מידע רגיש)

---

## שלב 4 – ניקוי ותחזוקת DB (Housekeeping) ⏭️

**סטטוס: מתוכנן**

### מטרות

- שמירה על DB קטן ובריא
- מניעת הצטברות נתונים מתים

### משימות

- ניקוי אוטומטי של:
  - Refresh Tokens שפגו תוקף
- בדיקת אינדקסים:
  - refresh_tokens
  - tables קריטיות
- ווידוא שאין orphan records

---

## שלב 5 – סגירה וקשיחות סופית ⏭️

**סטטוס: מתוכנן**

### מטרות

- לוודא שאין “פינות פתוחות”
- מעבר בטוח ל־Production

### משימ
