# Missions:

1. להוסיף נתיב של הרשמה
2. לסדר את ROLE_PERMISSIONS לפי מה שאני צריך

3. להמשיך מכאן:
   מה נבנה (מינימום פרקטי)

GET /admin/users/:userId/permission-overrides
מחזיר את כל החריגות של המשתמש

PUT /admin/users/:userId/permission-overrides
מחליף סט מלא (useful כשאתה רוצה “אמת אחת”)

POST /admin/users/:userId/permission-overrides
upsert של פריט אחד (הכי שימושי בפועל)

DELETE /admin/users/:userId/permission-overrides/:permission
מוחק override אחד

ובכל שינוי (PUT/POST/DELETE):

לקרוא invalidateUserOverridesCache(userId) כדי שזה יתעדכן מיד.
