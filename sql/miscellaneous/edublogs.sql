SELECT
  LOWER(SYS_USER.USERNAME) AS "Site Name",
  LOWER(SYS_USER.USERNAME) || '''s Blog' AS "Site Title",
  LOWER(SYS_USER.USERNAME) AS "Username",
  'null' AS "Password",
  CONTACT.EMAIL_ADDRESS AS "Email",
  'administrator' as "ROLE"

FROM TABLE(edumate.get_form_run_students((CURRENT DATE), (SELECT FORM_RUN_ID FROM FORM_RUN WHERE FORM_RUN = '2013 Year 10'))) GFRS

INNER JOIN STUDENT ON STUDENT.STUDENT_ID = GFRS.STUDENT_ID
INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
LEFT JOIN SYS_USER ON SYS_USER.CONTACT_ID = CONTACT.CONTACT_ID

ORDER BY SYS_USER.USERNAME