-- 14-day snapshot of what casuals used for what teacher when.
-- To do: Include start and endtimes with a view to calculating half or full day
-- (<= 4 is half day, > 4 and <= 8 is full day)

WITH CASUAL_BLOB_DAY_ONE AS
(
  SELECT
    DATE(CURRENT DATE - 14 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 14 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_TWO AS
(
  SELECT
    DATE(CURRENT DATE - 13 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 13 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_THREE AS
(
  SELECT
    DATE(CURRENT DATE - 11 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 11 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_FOUR AS
(
  SELECT
    DATE(CURRENT DATE - 10 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 10 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_FIVE AS
(
  SELECT
    DATE(CURRENT DATE - 9 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 9 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_SIX AS
(
  SELECT
    DATE(CURRENT DATE - 8 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 8 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_SEVEN AS
(
  SELECT
    DATE(CURRENT DATE - 7 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 7 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_EIGHT AS
(
  SELECT
    DATE(CURRENT DATE - 6 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 6 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_NINE AS
(
  SELECT
    DATE(CURRENT DATE - 5 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 5 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_TEN AS
(
  SELECT
    DATE(CURRENT DATE - 4 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 4 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_ELEVEN AS
(
  SELECT
    DATE(CURRENT DATE - 3 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 3 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_TWELVE AS
(
  SELECT
    DATE(CURRENT DATE - 2 DAYS) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 2 DAYS))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_THIRTEEN AS
(
  SELECT
    DATE(CURRENT DATE - 1 DAY) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE - 1 DAY))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

CASUAL_BLOB_DAY_FOURTEEN AS
(
  SELECT
    DATE(CURRENT DATE) AS "DATE_ON",
    SCHEDS.REPLACEMENT_STAFF_ID,
    SCHEDS.REPLACEMENT,
    SCHEDS.STAFF_ID,
    SCHEDS.PERIOD,
    SCHEDS.PERIOD_ID

  FROM TABLE(EDUMATE.GET_SCHEDULES_ON_DATE(DATE(CURRENT DATE))) SCHEDS

  INNER JOIN STAFF_EMPLOYMENT SE ON SE.STAFF_ID = SCHEDS.REPLACEMENT_STAFF_ID
  
  WHERE SCHEDS.REPLACEMENT_STAFF_ID IS NOT NULL
    AND SE.EMPLOYMENT_TYPE_ID IN (3,4)
),

ALL_CASUALS AS (
  SELECT * FROM CASUAL_BLOB_DAY_ONE
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_TWO
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_THREE
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_FOUR
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_FIVE
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_SIX
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_SEVEN
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_EIGHT
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_NINE
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_TEN
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_ELEVEN
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_TWELVE
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_THIRTEEN
    UNION ALL
  SELECT * FROM CASUAL_BLOB_DAY_FOURTEEN
),

CASUALS AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY REPLACEMENT_STAFF_ID) AS "SORT_ORDER",
    REPLACEMENT,
    DATE_ON,
    PERIOD,
    STAFF_ID

  FROM ALL_CASUALS

  ORDER BY REPLACEMENT_STAFF_ID, DATE_ON, STAFF_ID, PERIOD_ID
)

SELECT
  (CASE WHEN CASUALS.SORT_ORDER = 1 THEN REPLACEMENT ELSE NULL END) AS "REPLACEMENT",
  DATE_ON,
  PERIOD,
  CONTACT.FIRSTNAME || ' ' || CONTACT.SURNAME AS "ORIGINAL_TEACHER"

FROM CASUALS

INNER JOIN STAFF ON STAFF.STAFF_ID = CASUALS.STAFF_ID
INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STAFF.CONTACT_ID