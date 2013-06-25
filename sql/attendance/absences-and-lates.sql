-- To do: 

WITH
  -- Table: Reporting Periods - Start and End Dates
  -- NOTE: These will need to be turned into Edumate's [[Date picker]] style selectors.
  REPORT_DATES AS (
    SELECT
      TO_CHAR((CURRENT DATE), 'YYYY') AS "CURRENT_YEAR",
      (DATE('2013-01-31')) AS "SEVEN_START",
      (DATE('2013-06-06')) AS "SEVEN_END",
      (DATE('2013-01-31')) AS "EIGHT_START",
      (DATE('2013-06-06')) AS "EIGHT_END",
      (DATE('2013-01-31')) AS "NINE_START",
      (DATE('2013-06-06')) AS "NINE_END",

      (DATE('2013-01-31')) AS "TEN_START",
      (DATE('2013-05-13')) AS "TEN_END",
      (DATE('2013-01-31')) AS "ELEVEN_START",
      (DATE('2013-05-13')) AS "ELEVEN_END",
      (DATE('2012-10-10')) AS "TWELVE_START",
      (DATE('2013-05-13')) AS "TWELVE_END"
    
    FROM SYSIBM.SYSDUMMY1
  ),

STUDENT_ATTENDANCE_DATA AS (
  SELECT
    REPORT_DATES.SEVEN_START,
    REPORT_DATES.SEVEN_END,
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
  CROSS JOIN REPORT_DATES
  
  -- Absences join
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_DAILY ON ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID = DA.DAILY_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS LIKE '%Absence%' AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS NOT LIKE '%Partial Absence%'
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID NOT IN (20,21,22,23,24,25,26,27)
    AND DA.DATE_ON BETWEEN REPORT_DATES.SEVEN_START AND REPORT_DATES.SEVEN_END
  
  -- Lates join
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_AM ON ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID = DA.AM_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS LIKE '%Late%'
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID NOT IN (28,29,30,31)
    AND DA.DATE_ON BETWEEN REPORT_DATES.SEVEN_START AND REPORT_DATES.SEVEN_END
  
  WHERE FORM_RUN LIKE TO_CHAR((CURRENT DATE), 'YYYY') || ' Year %%'

  ORDER BY SURNAME, FORM_RUN
),

ABSENCES_LATES_COUNT AS (
  SELECT
    ROWNUMBER() OVER () AS "ROWNUMBER",
    SAD.STUDENT_ID,
    SAD.SURNAME,
    SAD.FORM_RUN,
    COUNT(ABSENCES) AS "ABSENCES_COUNT",
    COUNT(LATES) AS "LATES_COUNT"
  
  FROM STUDENT_ATTENDANCE_DATA SAD
  
  GROUP BY SAD.STUDENT_ID, SAD.SURNAME, SAD.FORM_RUN
  
  ORDER BY SAD.SURNAME
),

ABSENCES_LATES_AVG_TOTAL AS (
  SELECT
    ROW_NUMBER() OVER (),
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 07' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_07_STUDENTS",
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 08' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_08_STUDENTS",
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 09' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_09_STUDENTS",
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 10' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_10_STUDENTS",
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 11' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_11_STUDENTS",
    COUNT(CASE WHEN FORM_RUN = TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 12' THEN STUDENT_ID ELSE NULL END) AS "TOTAL_12_STUDENTS",
    AVG(ABSENCES_COUNT) AS "ABSENCES_AVG",
    SUM(ABSENCES_COUNT) AS "ABSENCES_TOTAL",
    AVG(LATES_COUNT) AS "LATES_AVG",
    SUM(LATES_COUNT) AS "LATES_TOTAL"
  
  FROM ABSENCES_LATES_COUNT ALC
)

SELECT DISTINCT
  SAD.FIRSTNAME,
  SAD.SURNAME,
  SAD.FORM_RUN,
  ALC.ABSENCES_COUNT,
  ALC.LATES_COUNT,
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_07_STUDENTS ELSE NULL END) AS "TOTAL_07_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_08_STUDENTS ELSE NULL END) AS "TOTAL_08_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_09_STUDENTS ELSE NULL END) AS "TOTAL_09_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_10_STUDENTS ELSE NULL END) AS "TOTAL_10_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_11_STUDENTS ELSE NULL END) AS "TOTAL_11_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.TOTAL_12_STUDENTS ELSE NULL END) AS "TOTAL_12_STUDENTS",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.ABSENCES_AVG ELSE NULL END) AS "ABSENCES_AVG",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.ABSENCES_TOTAL ELSE NULL END) AS "ABSENCES_TOTAL",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.LATES_AVG ELSE NULL END) AS "LATES_AVG",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN ALT.LATES_TOTAL ELSE NULL END) AS "LATES_TOTAL",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN TO_CHAR((SAD.SEVEN_START), 'DD Month YYYY') ELSE NULL END) AS "REPORT_PERIOD_START",
  (CASE WHEN ALC.ROWNUMBER = 1 THEN TO_CHAR((SAD.SEVEN_END), 'DD Month YYYY') ELSE NULL END) AS "REPORT_PERIOD_END"

FROM STUDENT_ATTENDANCE_DATA SAD

INNER JOIN ABSENCES_LATES_COUNT ALC ON ALC.STUDENT_ID = SAD.STUDENT_ID
INNER JOIN ABSENCES_LATES_AVG_TOTAL ALT ON ALC.STUDENT_ID = SAD.STUDENT_ID

ORDER BY FORM_RUN, SURNAME