-- Applications Submitted (applications-submitted.sql)

-- A list of all year 8, 9 or 10 students with the status of either 'Place Accepted' or 'Application Cancelled'
-- who have an application date that is greater than the start of the previous calendar year.

SELECT
  STUDENT_NUMBER AS "LOOKUP_CODE",
  CONTACT.SURNAME,
  CONTACT.FIRSTNAME,
  STU_ENROLMENT.DATE_APPLICATION,
  STUDENT_STATUS.STUDENT_STATUS,
  CASE WHEN FIRST_FORM_RUN IS NULL THEN EXP_FORM_RUN ELSE FIRST_FORM_RUN END AS "FORM_RUN",
  FORM_RUN_INFO,
  EXTERNAL_SCHOOL.EXTERNAL_SCHOOL AS "PREVIOUS_SCHOOL"

FROM TABLE(EDUMATE.GETALLSTUDENTSTATUS(CURRENT DATE)) GASS

INNER JOIN CONTACT ON CONTACT.CONTACT_ID = GASS.CONTACT_ID
LEFT JOIN STUDENT_STATUS ON STUDENT_STATUS.STUDENT_STATUS_ID = GASS.STUDENT_STATUS_ID
LEFT JOIN STU_ENROLMENT ON STU_ENROLMENT.STUDENT_ID = GASS.STUDENT_ID
LEFT JOIN EXTERNAL_SCHOOL ON EXTERNAL_SCHOOL.EXTERNAL_SCHOOL_ID = STU_ENROLMENT.PREV_SCHOOL_ID

WHERE
  GASS.STUDENT_STATUS_ID IN (1,6)
  AND
  STU_ENROLMENT.DATE_APPLICATION >= TO_CHAR((CURRENT DATE - 1 YEAR), 'YYYY') || '-01-01'
  AND
  (EXP_FORM_RUN LIKE '%%%% Year %%' AND EXP_FORM_RUN NOT LIKE '%%%% Year 07' AND EXP_FORM_RUN NOT LIKE '%%%% Year 12')

ORDER BY GASS.STUDENT_STATUS_ID DESC, FORM_RUN ASC, SURNAME