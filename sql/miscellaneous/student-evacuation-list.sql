WITH RAW_REPORT AS (
  SELECT
    TO_CHAR((CURRENT DATE), 'DD Month, YYYY') || ' at ' || CHAR(TIME(CURRENT TIMESTAMP),USA) AS "PRINTED",
    GCES.STUDENT_ID,
    STUDENT.STUDENT_NUMBER AS "LOOKUP_CODE",
    CONTACT.SURNAME,
    (CASE WHEN CONTACT.PREFERRED_NAME IS NULL THEN CONTACT.FIRSTNAME ELSE CONTACT.PREFERRED_NAME END) AS "FIRSTNAME",
    FORM_RUN.FORM_RUN,
    CLASS.CLASS AS "HOMEROOM",
    DAS.DAILY_ATTENDANCE_STATUS,
    GSL.LOCATION AS "CURRENT_LOCATION"
  
  FROM TABLE(EDUMATE.GET_CURRENTLY_ENROLED_STUDENTS(CURRENT DATE)) GCES
  
  INNER JOIN STUDENT ON STUDENT.STUDENT_ID = GCES.STUDENT_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
  INNER JOIN TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT DATE)) CURRENTS ON CURRENTS.STUDENT_ID = GCES.STUDENT_ID

  INNER JOIN FORM_RUN ON FORM_RUN.FORM_RUN_ID =
  (
    SELECT FORM_RUN.FORM_RUN_ID
    FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT DATE)) GRSFR
    INNER JOIN FORM_RUN ON GRSFR.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
    WHERE GRSFR.STUDENT_ID = GCES.STUDENT_ID
    FETCH FIRST 1 ROW ONLY
  )
  OR
  FORM_RUN.FORM_RUN_ID =
  (
    SELECT FORM_RUN.FORM_RUN_ID
    FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT DATE + 1 YEAR)) GRSFR
    INNER JOIN FORM_RUN ON GRSFR.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
    WHERE GRSFR.STUDENT_ID = GCES.STUDENT_ID
    FETCH FIRST 1 ROW ONLY
  )
  
  
  INNER JOIN DAILY_ATTENDANCE DA ON DA.STUDENT_ID = GCES.STUDENT_ID AND DATE_ON = (CURRENT DATE)
  INNER JOIN DAILY_ATTENDANCE_STATUS DAS ON DAS.DAILY_ATTENDANCE_STATUS_ID = DA.AM_ATTENDANCE_STATUS_ID
  INNER JOIN VIEW_STUDENT_CLASS_ENROLMENT VSCE ON VSCE.STUDENT_ID = GCES.STUDENT_ID
  INNER JOIN CLASS ON CLASS.CLASS_ID = VSCE.CLASS_ID AND CLASS.CLASS_TYPE_ID = 2 AND (VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE), 'YYYY') OR VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE + 1 YEAR), 'YYYY')) AND VSCE.END_DATE > (CURRENT_DATE)
  INNER JOIN TABLE(EDUMATE.GET_STUDENT_LOCATION(GCES.STUDENT_ID, (CURRENT TIMESTAMP))) GSL ON GSL.STUDENT_ID = GCES.STUDENT_ID
  
  WHERE FORM_RUN.FORM_RUN IN ('2013 Year 07', '2013 Year 08', '2013 Year 09', '2013 Year 10', '2014 Year 12')
  
  ORDER BY FORM_RUN.FORM_RUN, CLASS.CLASS, CONTACT.SURNAME, CONTACT.FIRSTNAME
)

SELECT DISTINCT
  PRINTED,
  LOOKUP_CODE,
  SURNAME,
  FIRSTNAME,
  FORM_RUN,
  HOMEROOM,
  DAILY_ATTENDANCE_STATUS,
  CURRENT_LOCATION

FROM RAW_REPORT

ORDER BY FORM_RUN, HOMEROOM, SURNAME, FIRSTNAME