WITH REPORT_VARS AS (
  SELECT
    TO_CHAR((CURRENT DATE), 'YYYY') AS "CURRENT_YEAR",
    (SELECT START_DATE FROM TERM WHERE TERM = 'Term 1' AND START_DATE LIKE TO_CHAR((CURRENT DATE), 'YYYY') || '-%%-%%' FETCH FIRST 1 ROW ONLY) AS "YEAR_START",
    (DATE(current date)) AS "REPORT_END",
    (DATE(current date - 11 DAYS)) AS "REPORT_FN_START"

  FROM SYSIBM.SYSDUMMY1
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
  INNER JOIN CLASS ON CLASS.CLASS_ID = VSCE.CLASS_ID AND CLASS.CLASS_TYPE_ID = 2 AND VSCE.ACADEMIC_YEAR = TO_CHAR((CURRENT DATE), 'YYYY') AND VSCE.END_DATE > (CURRENT DATE)
  CROSS JOIN REPORT_VARS
  
  WHERE
    (DA.DATE_ON BETWEEN REPORT_VARS.YEAR_START AND REPORT_VARS.REPORT_END)
    AND
    (
      DA.AM_ATTENDANCE_STATUS_ID IN (1,2,4,5,6,7,14,15,16,17,18,19)
      AND
      DA.PM_ATTENDANCE_STATUS_ID IN (1,2,4,5,6,7,14,15,16,17,18,19)
    )
),

-- Contains the fortnight calculator, which returns an integer that is the number of fortnights passed for the year to date.
-- SUMs the number of *school* days passed since the Report To date variable, divides by 10 (2 * 5-day school weeks)
ABSENCES_LATES_COUNTS AS (
  SELECT
    SAD.STUDENT_ID,
    SAD.CLASS,
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
    SUM(CASE WHEN SAD.AM IN (4,5,6) AND SAD.PM IN (4,5,6) THEN 1 ELSE 0 END) AS "EXPLAINED_ABSENCES",
    SUM(CASE WHEN SAD.AM IN (2,7) AND SAD.PM IN (2,7) THEN 1 ELSE 0 END) AS "UNEXPLAINED_ABSENCES",
    SUM(CASE WHEN SAD.AM IN (2,4,5,6,7) AND SAD.PM IN (2,4,5,6,7) THEN 1 ELSE 0 END) AS "ABSENCES_YTD",

    SUM(CASE WHEN SAD.DATE_ON BETWEEN SAD.REPORT_FN_START AND SAD.REPORT_END AND SAD.AM IN (14,15,16,17,18,19) THEN 1 ELSE 0 END) AS "FORTNIGHT_LATES",
    SUM(CASE WHEN SAD.AM IN (16,17,18,19) THEN 1 ELSE 0 END) AS "EXPLAINED_LATES",
    SUM(CASE WHEN SAD.AM IN (14,15) THEN 1 ELSE 0 END) AS "UNEXPLAINED_LATES",
    SUM(CASE WHEN SAD.AM IN (14,15,16,17,18,19) THEN 1 ELSE 0 END) AS "LATES_YTD"

  FROM STUDENT_ATTENDANCE_DATA SAD
  
  GROUP BY SAD.CLASS, SAD.STUDENT_ID
),

final_report AS (
  SELECT
    (CASE WHEN alc.class LIKE '%Connor%' THEN ('OConnor ' || RIGHT(alc.class, 13)) ELSE alc.class END) AS "GROUPING",
    -- FN is used in the footer of the template
    ALC.DIFF AS "FN",
    STUDENT.STUDENT_NUMBER AS "LOOKUP_CODE",
    (CASE WHEN contact.preferred_name IS null THEN contact.firstname ELSE contact.preferred_name END) AS "FIRSTNAME",
    CONTACT.SURNAME AS "SURNAME",
    (CASE
      WHEN form.short_name IN (7,8,9) THEN 'Middle School'
      WHEN form.short_name IN (10,11,12) THEN 'Senior School'
      ELSE null
    END) AS "SCHOOL",
    form.short_name AS "YEAR_GROUP",
    (CASE WHEN house.house LIKE '%Connor' THEN 'OConnor' ELSE house.house END) AS "HOUSE",
    RIGHT(ALC.CLASS, 3) AS "HOMEROOM",
    ALC.FORTNIGHT_ABSENCES AS "FN_ABSENCES",
    ALC.FORTNIGHT_LATES AS "FN_LATES",
    ALC.EXPLAINED_ABSENCES AS "EXP_ABSENCES_YTD",
    ALC.UNEXPLAINED_ABSENCES AS "UNEXP_ABSENCES_YTD",
    ALC.ABSENCES_YTD AS "ABSENCES_YTD",

    -- Cumulative Absences and Lates are (Absences for the year to date / Number of termly fortnights passed for the year to date)
    CAST(CAST(ALC.ABSENCES_YTD AS DECIMAL(4,2)) / ALC.DIFF AS DECIMAL(4,2)) AS "CUMUL_ABSENCES_AVERAGE",
    ALC.EXPLAINED_LATES AS "EXP_LATES_YTD",
    ALC.UNEXPLAINED_LATES AS "UNEXP_LATES_YTD",
    ALC.LATES_YTD AS "LATES_YTD",
    CAST(CAST(ALC.LATES_YTD AS DECIMAL(4,2)) / ALC.DIFF AS DECIMAL(4,2)) AS "CUMUL_LATES_AVERAGE",

    TO_CHAR((SELECT REPORT_FN_START FROM REPORT_VARS), 'Month DD YYYY') AS "REPORT_FN_START",
    TO_CHAR((SELECT REPORT_END FROM REPORT_VARS), 'Month DD YYYY') AS "REPORT_END"
  
  FROM TABLE(EDUMATE.GET_CURRENTLY_ENROLED_STUDENTS(current date)) GCES
  
  INNER JOIN STUDENT ON STUDENT.STUDENT_ID = GCES.STUDENT_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STUDENT.CONTACT_ID
  INNER JOIN house ON house.house_id = student.house_id

  INNER JOIN view_student_form_run vsfr ON vsfr.student_id = gces.student_id AND vsfr.academic_year = YEAR(current date)
  INNER JOIN form ON form.form_id = vsfr.form_id
  
  LEFT JOIN ABSENCES_LATES_COUNTS ALC ON ALC.STUDENT_ID = GCES.STUDENT_ID
)

SELECT * FROM final_report
ORDER BY grouping ASC, homeroom ASC, absences_ytd DESC, surname ASC, firstname ASC