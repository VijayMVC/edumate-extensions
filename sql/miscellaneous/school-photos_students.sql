SELECT
  STUDENT.STUDENT_NUMBER,
  CONTACT.FIRSTNAME,
  CONTACT.SURNAME,
  CONTACT.BIRTHDATE,
  VSCE.CLASS AS "HOMEROOM",
  FORM_RUN.FORM_RUN AS "YEAR_GROUP"

FROM TABLE(EDUMATE.GET_CURRENTLY_ENROLED_STUDENTS(CURRENT DATE)) GCES

INNER JOIN STUDENT ON STUDENT.STUDENT_ID = GCES.STUDENT_ID
INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
INNER JOIN VIEW_STUDENT_CLASS_ENROLMENT VSCE ON VSCE.STUDENT_ID = GCES.STUDENT_ID AND (VSCE.CLASS_TYPE_ID = 2 AND VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE), 'YYYY')) AND VSCE.END_DATE >= (current date)
INNER JOIN FORM_RUN ON FORM_RUN.FORM_RUN_ID =
  (
    SELECT FORM_RUN.FORM_RUN_ID
    FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT DATE)) GRSFR
    INNER JOIN FORM_RUN ON GRSFR.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
    WHERE GRSFR.STUDENT_ID = GCES.STUDENT_ID
    FETCH FIRST 1 ROW ONLY
  )

ORDER BY FORM_RUN.FORM_ID, VSCE.CLASS, CONTACT.SURNAME, CONTACT.FIRSTNAME