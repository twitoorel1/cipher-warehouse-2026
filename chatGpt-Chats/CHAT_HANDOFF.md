# CHAT_HANDOFF — מעבר לצ’אט הבא

## נושא הצ’אט

Data Integrity Hardening

---

## מה בוצע (Completed)

- ניתוח מלא של סכמת ה־SQL בפוקוס על Integrity
- הגדרת כללי Scope חד־משמעיים ל־storage_units (או גדוד או אוגדה)
- אכיפת all-or-nothing לכל קבוצות AES-GCM ב־TEL100 Voice
- אכיפת all-or-nothing לכל קבוצות AES-GCM ב־TEL100 Modem
- הוספת בדיקות חלון זמן ל־refresh_tokens
- יצירת סקריפטי SELECT לאימות נתונים לפני ALTER (Pre-flight checks)
- סגירת כל פערי Partial Writes ברמת DB

---

## מה פתוח (Open)

- אין

---

## החלטות קריטיות

- Integrity קריטי נאכף ב־DB באמצעות CHECK constraints ולא רק בקוד
- כל שדה מוצפן חייב להישמר כקבוצה אטומית (ct+iv+tag+kv)
- storage_units ללא שיוך (NULL-NULL) אסור לחלוטין
- אין להחליש או להסיר CHECKs בעתיד גם במחיר גמישות

---

## שלב נוכחי

Stage: Data Integrity Hardening  
Status: CLOSED

---

## Next Step (מדויק)

- Read Paths Audit
