WITH MAIN AS
(
  SELECT
    FIRSTNAME,
    SURNAME,
    DATE_ON CLASS_DATE,
    DATE(ATTENDANCE.LAST_UPDATED) AS "DATE_MARKED",
    TIME(ATTENDANCE.LAST_UPDATED) AS "WHEN_MARKED",
    CLASS,
    PERIOD.PERIOD

  FROM ATTENDANCE

  INNER JOIN LESSON ON LESSON.LESSON_ID = ATTENDANCE.LESSON_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = ATTENDANCE.RECORDED_BY
  INNER JOIN PERIOD_CLASS ON PERIOD_CLASS.PERIOD_CLASS_ID = LESSON.PERIOD_CLASS_ID
  INNER JOIN PERIOD ON PERIOD.PERIOD_ID = PERIOD_CLASS.PERIOD_CYCLE_DAY_ID
  INNER JOIN CLASS ON CLASS.CLASS_ID = PERIOD_CLASS.CLASS_ID
)

SELECT
  FIRSTNAME,
  SURNAME,
  CLASS,
  PERIOD,
  TO_CHAR(CLASS_DATE, 'DD-MM-YYYY') AS "CLASS_DATE",
  TO_CHAR(DATE_MARKED, 'DD-MM-YYYY') AS "DATE_MARKED",
  MAX(WHEN_MARKED) AS "WHEN_MARKED"

FROM MAIN

WHERE
  CLASS_DATE = '[[Date of Class=date]]'
  AND
  PERIOD = '[[Period=query_list(SELECT DISTINCT period FROM period)]]'

GROUP BY FIRSTNAME, SURNAME, PERIOD, CLASS, CLASS_DATE, DATE_MARKED
ORDER BY CLASS ASC, WHEN_MARKED DESC, DATE_MARKED DESC