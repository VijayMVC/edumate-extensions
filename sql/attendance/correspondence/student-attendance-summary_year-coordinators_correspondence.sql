-- Student Attendance Summary

-- A summative report that lists student attendance statistics over a fortnight, as well as year to date.
-- This report calculates explained/unexplained absences/lates, as well as cumulative absences/lates as an average per fortnight.

-- Results are grouped by home room, and then sorted by *'Absences YTD'*

-- This report pipes it's results to a SXW template (attendance/student-attendance-summary.sxw) which is emailed to
-- Year Coordinators as well as Pastoral Assistants every fortnight on Friday night.


-- Generic REPORT_VARS subquery for DRYness
WITH REPORT_VARS AS (
  SELECT
    TO_CHAR((CURRENT DATE), 'YYYY') AS "CURRENT_YEAR",
    (SELECT START_DATE FROM TERM WHERE TERM = 'Term 1' AND START_DATE LIKE (TO_CHAR((CURRENT DATE), 'YYYY')) || '-%%-%%' FETCH FIRST 1 ROW ONLY) AS "YEAR_START",
    (DATE(CURRENT DATE)) AS "REPORT_END",
    (DATE(CURRENT DATE) - 11 DAYS) AS "REPORT_FN_START"

  FROM SYSIBM.SYSDUMMY1
),

YC_VARS AS (
  SELECT
    -- Variables for Year Coordinators
    21671 AS "SEVEN_YC",
    21348 AS "EIGHT_YC",
    21596 AS "NINE_YC",
    54289 AS "TEN_YC",
    21697 AS "ELEVEN_YC",
    21666 AS "TWELVE_YC"
  
  FROM SYSIBM.SYSDUMMY1
),

BOTH_GROUPS AS (
  SELECT
    CONTACT.CONTACT_ID,
    (CASE
      WHEN CONTACT.CONTACT_ID = YC_VARS.SEVEN_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 07'
      WHEN CONTACT.CONTACT_ID = YC_VARS.EIGHT_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 08'
      WHEN CONTACT.CONTACT_ID = YC_VARS.NINE_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 09'
      WHEN CONTACT.CONTACT_ID = YC_VARS.TEN_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 10'
      WHEN CONTACT.CONTACT_ID = YC_VARS.ELEVEN_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 11'
      WHEN CONTACT.CONTACT_ID = YC_VARS.TWELVE_YC THEN TO_CHAR((CURRENT DATE), 'YYYY') || ' Year 12'
      ELSE NULL
    END) AS "FORM_RUN"

  FROM CONTACT
  CROSS JOIN YC_VARS
  WHERE CONTACT.CONTACT_ID IN (YC_VARS.SEVEN_YC, YC_VARS.EIGHT_YC, YC_VARS.NINE_YC, YC_VARS.TEN_YC, YC_VARS.ELEVEN_YC, YC_VARS.TWELVE_YC)
),

-- Grabs all relevant attendance data ranging from the start of the academic year to the Report To date variable.
STUDENT_ATTENDANCE_DATA AS (
  SELECT DISTINCT
    REPORT_VARS.REPORT_END,
    REPORT_VARS.YEAR_START,
    REPORT_VARS.REPORT_FN_START,
    DA.STUDENT_ID,
    CLASS.CLASS,
    DA.DATE_ON,
    DA.AM_ATTENDANCE_STATUS_ID AS "AM",
    DA.PM_ATTENDANCE_STATUS_ID AS "PM"
  
  FROM DAILY_ATTENDANCE DA
  
  INNER JOIN VIEW_STUDENT_CLASS_ENROLMENT VSCE ON VSCE.STUDENT_ID = DA.STUDENT_ID
  INNER JOIN CLASS ON CLASS.CLASS_ID = VSCE.CLASS_ID AND CLASS.CLASS_TYPE_ID = 2 AND VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE), 'YYYY') AND VSCE.END_DATE > (CURRENT_DATE)
  CROSS JOIN REPORT_VARS
  
  WHERE
    (DA.DATE_ON BETWEEN REPORT_VARS.YEAR_START AND REPORT_VARS.REPORT_END)
    AND
    (
      DA.AM_ATTENDANCE_STATUS_ID IN (1,2,3,4,5,6,7,14,15,16,17,18,19)
      AND
      DA.PM_ATTENDANCE_STATUS_ID IN (1,2,3,4,5,6,7,14,15,16,17,18,19)
    )
),

-- Contains the fortnight calculator, which returns an integer that is the number of fortnights passed for the year to date.
-- SUMs the number of *school* days passed since the Report To date variable, divides by 10 (2 * 5-day school weeks)
ABSENCES_LATES_COUNTS AS (
  SELECT
    SAD.STUDENT_ID,
    (SELECT
      (SUM(CASE WHEN GTRD.TERM_DATE <= (SELECT REPORT_END FROM REPORT_VARS) THEN 1 ELSE 0 END) / 10)
    FROM TABLE(EDUMATE.GET_TIMETABLE_RUNNING_DATES(
      (SELECT TIMETABLE_ID
      FROM TERM WHERE TERM = 'Term 1'
      AND
      START_DATE LIKE (TO_CHAR((CURRENT DATE), 'YYYY')) || '-%%-%%' FETCH FIRST 1 ROW ONLY))) GTRD
    INNER JOIN TERM ON TERM.TERM_ID = GTRD.TERM_ID
    WHERE GTRD.DAY_INDEX NOT IN (888, 999)
    ) AS "DIFF",
    -- Conditional SUMs to calcuate total instances of fortnight, explained YTD, unexplained YTD, and total YTD absences/lates.
    SUM(CASE WHEN SAD.DATE_ON BETWEEN SAD.REPORT_FN_START AND SAD.REPORT_END AND (SAD.AM IN (2,3,4,5,6,7) AND SAD.PM IN (2,3,4,5,6,7)) THEN 1 ELSE 0 END) AS "FORTNIGHT_ABSENCES",
    SUM(CASE WHEN SAD.AM IN (3,4,5,6) AND SAD.PM IN (3,4,5,6) THEN 1 ELSE 0 END) AS "EXPLAINED_ABSENCES",
    SUM(CASE WHEN SAD.AM IN (2,7) AND SAD.PM IN (2,7) THEN 1 ELSE 0 END) AS "UNEXPLAINED_ABSENCES",
    SUM(CASE WHEN SAD.AM IN (2,3,4,5,6,7) AND SAD.PM IN (2,3,4,5,6,7) THEN 1 ELSE 0 END) AS "ABSENCES_YTD",

    SUM(CASE WHEN SAD.DATE_ON BETWEEN SAD.REPORT_FN_START AND SAD.REPORT_END AND SAD.AM IN (14,15,16,17,18,19) THEN 1 ELSE 0 END) AS "FORTNIGHT_LATES",
    SUM(CASE WHEN SAD.AM IN (16,17,18,19) THEN 1 ELSE 0 END) AS "EXPLAINED_LATES",
    SUM(CASE WHEN SAD.AM IN (14,15) THEN 1 ELSE 0 END) AS "UNEXPLAINED_LATES",
    SUM(CASE WHEN SAD.AM IN (14,15,16,17,18,19) THEN 1 ELSE 0 END) AS "LATES_YTD"

  FROM STUDENT_ATTENDANCE_DATA SAD
  
  GROUP BY SAD.CLASS, SAD.STUDENT_ID
)

SELECT
  -- FN is used in the footer of the template
  (CASE WHEN ROW_NUMBER() OVER (PARTITION BY FORM_RUN.FORM_RUN) = 1 THEN ALC.DIFF ELSE NULL END) AS "FN",
  STUDENT.STUDENT_NUMBER,
  CONTACT.FIRSTNAME,
  CONTACT.SURNAME,
  FORM_RUN.FORM_RUN,
  CLASS.CLASS,
  CAST(ALC.FORTNIGHT_ABSENCES AS VARCHAR(3)) AS "FORTNIGHT_ABSENCES",
  CAST(ALC.FORTNIGHT_LATES AS VARCHAR(3)) AS "FORTNIGHT_LATES",
  CAST(ALC.EXPLAINED_ABSENCES AS VARCHAR(3)) AS "EXPLAINED_ABSENCES",
  CAST(ALC.UNEXPLAINED_ABSENCES AS VARCHAR(3)) AS "UNEXPLAINED_ABSENCES",
  CAST(ALC.ABSENCES_YTD AS VARCHAR(3)) AS "ABSENCES_YTD",

  -- Cumulative Absences and Lates are (Absences for the year to date / Number of termly fortnights passed for the year to date)
  CAST((CAST(ALC.ABSENCES_YTD AS DECIMAL(3,1)) / CAST(ALC.DIFF AS DECIMAL(3,1))) AS DECIMAL(3,2)) AS "CUMUL_ABSENCES",
  CAST(ALC.EXPLAINED_LATES AS VARCHAR(3)) AS "EXPLAINED_LATES",
  CAST(ALC.UNEXPLAINED_LATES AS VARCHAR(3)) AS "UNEXPLAINED_LATES",
  CAST(ALC.LATES_YTD AS VARCHAR(3)) AS "LATES_YTD",
  CAST((CAST(ALC.LATES_YTD AS DECIMAL(3,1)) / CAST(ALC.DIFF AS DECIMAL(3,1))) AS DECIMAL(3,2)) AS "CUMUL_LATES",
  TO_CHAR((REPORT_VARS.REPORT_FN_START), 'Month DD YYYY') AS "REPORT_FN_START",
  TO_CHAR((REPORT_VARS.REPORT_END), 'Month DD YYYY') AS "REPORT_END",
  BOTH_GROUPS.CONTACT_ID

FROM STUDENT

INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
-- Only join the lowest form run. This fixes students who are in two forms appearing in two forms.
INNER JOIN FORM_RUN ON FORM_RUN.FORM_RUN_ID =
(
    SELECT FORM_RUN.FORM_RUN_ID
    FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT DATE)) GRSFR
    INNER JOIN FORM_RUN ON GRSFR.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
    WHERE GRSFR.STUDENT_ID = STUDENT.STUDENT_ID
    FETCH FIRST 1 ROW ONLY
)

INNER JOIN VIEW_STUDENT_CLASS_ENROLMENT VSCE ON VSCE.STUDENT_ID = STUDENT.STUDENT_ID
INNER JOIN CLASS ON CLASS.CLASS_ID = VSCE.CLASS_ID AND CLASS.CLASS_TYPE_ID = 2 AND VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE), 'YYYY') AND VSCE.END_DATE > (CURRENT_DATE)
INNER JOIN ABSENCES_LATES_COUNTS ALC ON ALC.STUDENT_ID = STUDENT.STUDENT_ID
INNER JOIN BOTH_GROUPS ON BOTH_GROUPS.FORM_RUN = FORM_RUN.FORM_RUN

CROSS JOIN REPORT_VARS

WHERE BOTH_GROUPS.CONTACT_ID = [[mainquery.contact_id]]

ORDER BY FORM_RUN.FORM_RUN, CLASS.CLASS, ALC.ABSENCES_YTD DESC, CONTACT.SURNAME