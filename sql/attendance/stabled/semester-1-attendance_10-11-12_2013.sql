WITH TEN_ELEVEN AS
(
  SELECT

	--Absences by gender, then form
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 10' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "10_BOYS_ABSENCES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 10' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "10_GIRLS_ABSENCES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 11' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "11_BOYS_ABSENCES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 11' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "11_GIRLS_ABSENCES",

	--Lates by gender, then form
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 10' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "10_BOYS_LATES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 10' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "10_GIRLS_LATES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 11' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "11_BOYS_LATES",
	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 11' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "11_GIRLS_LATES"

  FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT_DATE)) A
  
  INNER JOIN FORM_RUN ON A.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
  INNER JOIN STUDENT ON A.STUDENT_ID = STUDENT.STUDENT_ID
  INNER JOIN CONTACT ON STUDENT.CONTACT_ID = CONTACT.CONTACT_ID
  INNER JOIN GENDER ON CONTACT.GENDER_ID = GENDER.GENDER_ID

  INNER JOIN DAILY_ATTENDANCE ON A.STUDENT_ID = DAILY_ATTENDANCE.STUDENT_ID

  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_DAILY ON ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID = DAILY_ATTENDANCE.DAILY_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS LIKE '%Absence%' AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS NOT LIKE '%Partial Absence%'
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID NOT IN (20,21,22,23,24,25,26,27)
    AND DAILY_ATTENDANCE.DATE_ON BETWEEN '2013-01-31' AND '2013-05-13'
			
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_AM ON ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID = DAILY_ATTENDANCE.AM_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS LIKE '%Late%'
   	AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID NOT IN (28,29,30,31)
   	AND DAILY_ATTENDANCE.DATE_ON BETWEEN '2013-01-31' AND '2013-05-13'
  
  WHERE (ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS IS NOT NULL OR ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS IS NOT NULL)
),

TWELVE AS
(
  SELECT
  
  	--Absences by gender, then form
  	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 12' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "12_BOYS_ABSENCES",
  	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 12' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS ELSE null END) AS "12_GIRLS_ABSENCES",
  
  	--Lates by gender, then form
  	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 12' AND GENDER.GENDER_ID = 2 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "12_BOYS_LATES",
  	COUNT(CASE WHEN FORM_RUN.FORM_RUN LIKE '%%%% Year 12' AND GENDER.GENDER_ID = 3 THEN ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS ELSE null END) AS "12_GIRLS_LATES"
  
  FROM TABLE(EDUMATE.GET_ENROLED_STUDENTS_FORM_RUN(CURRENT_DATE)) A
  
  INNER JOIN FORM_RUN ON A.FORM_RUN_ID = FORM_RUN.FORM_RUN_ID
  INNER JOIN STUDENT ON A.STUDENT_ID = STUDENT.STUDENT_ID
  INNER JOIN CONTACT ON STUDENT.CONTACT_ID = CONTACT.CONTACT_ID
  INNER JOIN GENDER ON CONTACT.GENDER_ID = GENDER.GENDER_ID

  INNER JOIN DAILY_ATTENDANCE ON A.STUDENT_ID = DAILY_ATTENDANCE.STUDENT_ID

  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_DAILY ON ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID = DAILY_ATTENDANCE.DAILY_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS LIKE '%Absence%' AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS NOT LIKE '%Partial Absence%'
    AND ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS_ID NOT IN (20,21,22,23,24,25,26,27)
    AND DAILY_ATTENDANCE.DATE_ON BETWEEN '2012-10-10' AND '2013-05-13'
  			
  LEFT JOIN DAILY_ATTENDANCE_STATUS ATTENDANCE_STATUS_AM ON ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID = DAILY_ATTENDANCE.AM_ATTENDANCE_STATUS_ID
    AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS LIKE '%Late%'
   	AND ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS_ID NOT IN (28,29,30,31)
   	AND DAILY_ATTENDANCE.DATE_ON BETWEEN '2012-10-10' AND '2013-05-13'
  
  WHERE (ATTENDANCE_STATUS_DAILY.DAILY_ATTENDANCE_STATUS IS NOT NULL OR ATTENDANCE_STATUS_AM.DAILY_ATTENDANCE_STATUS IS NOT NULL)
),

TEN_ELEVEN_TWELVE AS
(
  SELECT * FROM TEN_ELEVEN, TWELVE
)

SELECT
  '31/01/2013' AS "10_11_REPORT_START",
  '10/10/2012' AS "12_REPORT_START",
  '13/05/2013' AS "REPORT_END",
  "10_BOYS_ABSENCES",
  "10_GIRLS_ABSENCES",
  SUM("10_BOYS_ABSENCES"+"10_GIRLS_ABSENCES") AS "10_ABSENCES",
  "11_BOYS_ABSENCES",
  "11_GIRLS_ABSENCES",
  SUM("11_BOYS_ABSENCES"+"11_GIRLS_ABSENCES") AS "11_ABSENCES",
  "10_BOYS_LATES",
  "10_GIRLS_LATES",
  SUM("10_BOYS_LATES"+"10_GIRLS_LATES") AS "10_LATES",
  "11_BOYS_LATES",
  "11_GIRLS_LATES",
  SUM("11_BOYS_LATES"+"11_GIRLS_LATES") AS "11_LATES",
  "12_BOYS_ABSENCES",
  "12_GIRLS_ABSENCES",
  SUM("12_BOYS_ABSENCES"+"12_GIRLS_ABSENCES") AS "12_ABSENCES",
  "12_BOYS_LATES",
  "12_GIRLS_LATES",
  SUM("12_BOYS_LATES"+"12_GIRLS_LATES") AS "12_LATES",
  SUM("10_BOYS_ABSENCES"+"11_BOYS_ABSENCES"+"12_BOYS_ABSENCES") AS "ALL_BOYS_ABSENCES",
  SUM("10_BOYS_LATES"+"11_BOYS_LATES"+"12_BOYS_LATES") AS "ALL_BOYS_LATES",
  SUM("10_GIRLS_ABSENCES"+"11_GIRLS_ABSENCES"+"12_GIRLS_ABSENCES") AS "ALL_GIRLS_ABSENCES",
  SUM("10_GIRLS_LATES"+"11_GIRLS_LATES"+"12_GIRLS_LATES") AS "ALL_GIRLS_LATES",
  SUM("10_BOYS_ABSENCES"+"11_BOYS_ABSENCES"+"12_BOYS_ABSENCES"+"10_BOYS_LATES"+"11_BOYS_LATES"+"12_BOYS_LATES") AS "ALL_BOYS_ABSENCES_AND_LATES",
  SUM("10_GIRLS_ABSENCES"+"11_GIRLS_ABSENCES"+"12_GIRLS_ABSENCES"+"10_GIRLS_LATES"+"11_GIRLS_LATES"+"12_GIRLS_LATES") AS "ALL_GIRLS_ABSENCES_AND_LATES",
  SUM("10_BOYS_ABSENCES"+"11_BOYS_ABSENCES"+"12_BOYS_ABSENCES"+"10_GIRLS_ABSENCES"+"11_GIRLS_ABSENCES"+"12_GIRLS_ABSENCES") AS "ALL_ABSENCES",
  SUM("10_BOYS_LATES"+"11_BOYS_LATES"+"12_BOYS_LATES"+"10_GIRLS_LATES"+"11_GIRLS_LATES"+"12_GIRLS_LATES") AS "ALL_LATES"

FROM TEN_ELEVEN_TWELVE

GROUP BY
  "10_BOYS_ABSENCES",
  "10_GIRLS_ABSENCES",
  "11_BOYS_ABSENCES",
  "11_GIRLS_ABSENCES",
  "10_BOYS_LATES",
  "10_GIRLS_LATES",
  "11_BOYS_LATES",
  "11_GIRLS_LATES",
  "12_BOYS_ABSENCES",
  "12_GIRLS_ABSENCES",
  "12_BOYS_LATES",
  "12_GIRLS_LATES"