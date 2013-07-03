WITH REPORT_VARS AS (
  SELECT
    TO_CHAR((CURRENT DATE), 'YYYY') AS "CURRENT_YEAR",
    (DATE((CURRENT DATE) - 14 DAYS)) AS "REPORT_START",
    (DATE(CURRENT DATE)) AS "REPORT_END",
    (SELECT START_DATE FROM TERM WHERE TERM = 'Term 1' AND START_DATE LIKE (TO_CHAR((CURRENT DATE), 'YYYY')) || '-%%-%%' FETCH FIRST 1 ROW ONLY) AS "YEAR_START"

  FROM SYSIBM.SYSDUMMY1
),

STUDENT_ATTENDANCE_DATA AS (
  SELECT
    REPORT_VARS.REPORT_START,
    REPORT_VARS.REPORT_END,
    REPORT_VARS.YEAR_START,
    GSFR.STUDENT_ID,
    CONTACT.FIRSTNAME,
    CONTACT.SURNAME,
    FORM_RUN.FORM_RUN,
    ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS AS "ABSENCES",
    ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS AS "LATES" 
  
  FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT_DATE)) GSFR
  
  INNER JOIN DAILY_ATTENDANCE DA ON DA.STUDENT_ID = GSFR.STUDENT_ID
  INNER JOIN FORM_RUN ON FORM_RUN.FORM_RUN_ID = GSFR.FORM_RUN_ID
  INNER JOIN STUDENT ON STUDENT.STUDENT_ID = GSFR.STUDENT_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
  CROSS JOIN REPORT_VARS
  
  -- Absences join
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_DAILY ON ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID = DA.DAILY_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS LIKE '%Absence%' AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS NOT LIKE '%Partial Absence%'
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID NOT IN (20,21,22,23,24,25,26,27)
    AND DA.DATE_ON BETWEEN REPORT_VARS.YEAR_START AND REPORT_VARS.REPORT_END
  
  -- Lates join
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_AM ON ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID = DA.AM_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS LIKE '%Late%'
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID NOT IN (28,29,30,31)
    AND DA.DATE_ON BETWEEN REPORT_VARS.YEAR_START AND REPORT_VARS.REPORT_END
  
  --WHERE 

  ORDER BY SURNAME, FORM_RUN
)

SELECT * FROM STUDENT_ATTENDANCE_DATA