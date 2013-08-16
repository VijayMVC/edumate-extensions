WITH REPORT_VARS AS (
  SELECT
    (SELECT
      (SUM(CASE WHEN GTRD.TERM_DATE <= (CURRENT DATE) THEN 1 ELSE 0 END) / 10)
    FROM TABLE(EDUMATE.GET_TIMETABLE_RUNNING_DATES(
      (SELECT TIMETABLE_ID
      FROM TERM WHERE TERM = 'Term 1'
      AND
      START_DATE LIKE (TO_CHAR((CURRENT DATE), 'YYYY')) || '-%%-%%' FETCH FIRST 1 ROW ONLY))) GTRD
    INNER JOIN TERM ON TERM.TERM_ID = GTRD.TERM_ID
    WHERE GTRD.DAY_INDEX NOT IN (888, 999)
    ) AS "FN",
    (DATE(CURRENT DATE)) AS "REPORT_END",
    (DATE(CURRENT DATE) - 11 DAYS) AS "REPORT_FN_START"
  
  FROM SYSIBM.SYSDUMMY1
),

HRS AS (
  SELECT
    (CASE
      WHEN CLASS LIKE '7%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 07'
      WHEN CLASS LIKE '8%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 08'
      WHEN CLASS LIKE '9%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 09'
      WHEN CLASS LIKE '10%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 10'
      WHEN CLASS LIKE '11%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 11'
      WHEN CLASS LIKE '12%' THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 12'
      ELSE NULL
    END) AS "FORM_RUN",
    CLASS
  
  FROM TABLE(EDUMATE.GET_ACTIVE_AY_CLASSES((SELECT ACADEMIC_YEAR_ID FROM ACADEMIC_YEAR WHERE ACADEMIC_YEAR = YEAR(CURRENT DATE)))) GAAC
  INNER JOIN CLASS ON CLASS.CLASS_ID = GAAC.CLASS_ID
  WHERE CLASS.CLASS_TYPE_ID = 2
  ORDER BY "FORM_RUN", CLASS
),

YEAR_COS AS (
  SELECT
    CONTACT.CONTACT_ID,
    FORM_RUN.FORM_RUN,
    (CASE
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 07' THEN 'Year Coordinator for Year 7'
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 08' THEN 'Year Coordinator for Year 8'
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 09' THEN 'Year Coordinator for Year 9'
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 10' THEN 'Year Coordinator for Year 10'
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 11' THEN 'Year Coordinator for Year 11'
      WHEN FORM_RUN.FORM_RUN LIKE '% Year 12' THEN 'Year Coordinator for Year 12'
      ELSE NULL
    END) AS "ROLE"
  
  FROM FORM_RUN
  
  INNER JOIN STAFF ON STAFF.STAFF_ID = FORM_RUN.COORDINATOR_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STAFF.CONTACT_ID
  
  WHERE FORM_RUN.FORM_RUN LIKE TO_CHAR((CURRENT DATE), 'YYYY') || ' %'
)

SELECT
  YEAR_COS.CONTACT_ID,
  CONTACT.SURNAME,
  CONTACT.FIRSTNAME,
  YEAR_COS.FORM_RUN,
  HRS.CLASS,
  YEAR_COS.ROLE,
  TO_CHAR((REPORT_VARS.REPORT_FN_START), 'Month DD YYYY') AS "REPORT_FN_START",
  TO_CHAR((REPORT_VARS.REPORT_END), 'Month DD YYYY') AS "REPORT_END",
  TO_CHAR((CURRENT TIMESTAMP), 'Month DD, YYYY') AS "GENERATED_DATE",
  CHAR(TIME(CURRENT TIMESTAMP),USA) AS "GENERATED_TIME",
  REPORT_VARS.FN

FROM YEAR_COS

INNER JOIN CONTACT ON CONTACT.CONTACT_ID = YEAR_COS.CONTACT_ID
INNER JOIN HRS ON HRS.FORM_RUN = YEAR_COS.FORM_RUN
CROSS JOIN REPORT_VARS

ORDER BY YEAR_COS.FORM_RUN, YEAR_COS.ROLE DESC