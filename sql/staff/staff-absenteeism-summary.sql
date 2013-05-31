WITH YTD_RAW AS
(
  SELECT
    YTD.STAFF_ID,
    AWAY_REASON_ID,
    TO_CHAR((FROM_DATE), 'DD-MM-YYYY') AS "FROM_DATE",
    TIME(FROM_DATE) AS "FROM_TIME",
    TIME(TO_DATE) AS "TO_TIME",
    TO_CHAR((TO_DATE), 'DD-MM-YYYY') AS "TO_DATE",
    CASE WHEN
      TO_CHAR((TO_DATE), 'DD-MM-YYYY') != TO_CHAR((FROM_DATE), 'DD-MM-YYYY')
        THEN ((DAYS (TO_DATE) - DAYS (FROM_DATE)) + 1)
        ELSE
          DECIMAL(ROUND((TO_CHAR((HOUR(TIME(TIME(TO_DATE)) - (TIME(FROM_DATE))) * 60)
            +
          MINUTE(TIME(TIME(TO_DATE)) - (TIME(FROM_DATE)))) / 480), 2), 31, 2)
          END AS "DAYS_ABSENT"

  FROM STAFF_AWAY YTD
  
  INNER JOIN STAFF ON STAFF.STAFF_ID = YTD.STAFF_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STAFF.CONTACT_ID
  
  WHERE
    TO_CHAR((FROM_DATE), 'YYYY') = TO_CHAR((CURRENT_DATE), 'YYYY') OR FROM_DATE < CURRENT_DATE
),

YTD_DATA AS
(
  SELECT
    STAFF_ID,
    CASE WHEN YTD_RAW.DAYS_ABSENT = 2.87 THEN 1.0 ELSE YTD_RAW.DAYS_ABSENT END AS "DAYS_ABSENT_YTD"
  
  FROM YTD_RAW
  
  GROUP BY STAFF_ID, DAYS_ABSENT
),

YTD_SUM AS
(
  SELECT
    STAFF_ID,
    SUM(DAYS_ABSENT_YTD) AS "TOTAL_DAYS_ABSENT_FOR_YEAR"
  
  FROM YTD_DATA

  GROUP BY STAFF_ID
),

FN_RAW AS
(
  SELECT
    ROW_NUMBER() OVER (PARTITION BY YTD.STAFF_ID ORDER BY CONTACT.SURNAME ASC) AS "SORT_ORDER",
    YTD.STAFF_ID,
    AWAY_REASON_ID,
    CASE WHEN TO_CHAR(FROM_DATE, 'DD-MM-YYYY') < TO_CHAR((CURRENT_DATE - 14 DAYS), 'DD-MM-YYYY') THEN TO_CHAR((CURRENT DATE - 14 DAYS), 'Month DD') ELSE TO_CHAR(FROM_DATE, 'Month DD - HH:MM PM') END AS "EFFECTIVE_START",
    CASE WHEN TO_CHAR(TO_DATE, 'DD-MM-YYYY') > TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY') THEN TO_CHAR((CURRENT_DATE), 'Month DD') ELSE TO_CHAR(TO_DATE, 'Month DD - HH:MM PM') END AS "EFFECTIVE_END",
    CASE WHEN
      TO_CHAR((TO_DATE), 'DD-MM-YYYY') != TO_CHAR((FROM_DATE), 'DD-MM-YYYY')
        THEN (
          (DAYS(CASE WHEN TO_CHAR(TO_DATE, 'DD-MM-YYYY') > TO_CHAR((CURRENT_DATE), 'DD-MM-YYYY') THEN (CURRENT_DATE) ELSE TO_DATE END))
            -
          (DAYS(CASE WHEN TO_CHAR(FROM_DATE, 'DD-MM-YYYY') < TO_CHAR((CURRENT_DATE - 14 DAYS), 'DD-MM-YYYY') THEN (CURRENT_DATE - 14 DAYS) ELSE FROM_DATE END))
            + 1
        )
        ELSE (CASE
                WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) <= 3 THEN 0.25
                WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) = 4 THEN 0.5
                WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) BETWEEN 4 AND 6 THEN 0.75
                WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) > 4 THEN 1.0 END)
    END AS "DAYS_ABSENT"
  
  FROM STAFF_AWAY YTD
  
  INNER JOIN STAFF ON STAFF.STAFF_ID = YTD.STAFF_ID
  INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STAFF.CONTACT_ID
  
  WHERE
    FROM_DATE <= CURRENT_DATE AND TO_DATE > (CURRENT_DATE - 14 DAYS)
        AND
    TO_CHAR(FROM_DATE, 'YYYY') = TO_CHAR(CURRENT_DATE, 'YYYY')

  ORDER BY SURNAME, SORT_ORDER
),

AWAY_FROM_CLASS AS
(
  SELECT
      AFC.STAFF_ID,
      CASE WHEN
        TO_CHAR((TO_DATE), 'DD-MM-YYYY') != TO_CHAR((FROM_DATE), 'DD-MM-YYYY')
          THEN (
            (DAYS(CASE WHEN TO_CHAR(TO_DATE, 'DD-MM-YYYY') > TO_CHAR((CURRENT_DATE), 'DD-MM-YYYY') THEN (CURRENT_DATE) ELSE TO_DATE END))
              -
            (DAYS(CASE WHEN TO_CHAR(FROM_DATE, 'DD-MM-YYYY') < TO_CHAR((CURRENT_DATE - 14 DAYS), 'DD-MM-YYYY') THEN (CURRENT_DATE - 14 DAYS) ELSE FROM_DATE END))
              + 1
          )
          ELSE (CASE
                  WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) <= 3 THEN 0.25
                  WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) = 4 THEN 0.5
                  WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) BETWEEN 4 AND 6 THEN 0.75
                  WHEN HOUR(TIME(TO_DATE) - TIME(FROM_DATE)) > 4 THEN 1.0 END)
      END AS "AWAY_FROM_CLASS"
  
  FROM STAFF_AWAY AFC
  
  -- Limit to report scope, and AWAY_FROM_CLASS by Away Reasons of:
  --  * Sick
  --  * PDN
  --  * Annual Leave
  --  * Professional Development
  --  * Time In-Lieu
  --  * Leave
  --  * Meeting
  --  * Late
  --  * School Duties
  --  * HSC Marking
  --  * Funded Professional Development
  --  * Leave Without Pay
  WHERE
    AWAY_REASON_ID IN (1,2,3,5,6,7,9,10,25,49,74,75)
      AND
    FROM_DATE <= CURRENT_DATE AND TO_DATE > (CURRENT_DATE - 14 DAYS)
      AND
    TO_CHAR(FROM_DATE, 'YYYY') = TO_CHAR(CURRENT_DATE, 'YYYY')
)

SELECT
  SORT_ORDER,
  TO_CHAR((CURRENT_DATE), 'YYYY') AS "CURRENT_YEAR",
  TO_CHAR((CURRENT_DATE - 14 DAYS), 'Month DD, YYYY' ) AS "FNIGHT_BEGIN",
  TO_CHAR((CURRENT_DATE), 'Month DD, YYYY') AS "FNIGHT_END",
  FN_RAW.STAFF_ID,
	CASE WHEN SORT_ORDER = 1 THEN CONTACT.FIRSTNAME ELSE '' END AS "FIRSTNAME",
  CASE WHEN SORT_ORDER = 1 THEN CONTACT.SURNAME ELSE '' END AS "SURNAME",
  AWAY_REASON.AWAY_REASON,
  FN_RAW.EFFECTIVE_START,
  FN_RAW.EFFECTIVE_END,
  FN_RAW.DAYS_ABSENT,
  CASE WHEN SORT_ORDER = 1 THEN YTD_SUM.TOTAL_DAYS_ABSENT_FOR_YEAR ELSE NULL END AS "TOTAL_DAYS_ABSENT_FOR_YEAR"

FROM FN_RAW

INNER JOIN STAFF ON STAFF.STAFF_ID = FN_RAW.STAFF_ID
INNER JOIN CONTACT ON CONTACT.CONTACT_ID = STAFF.CONTACT_ID

INNER JOIN AWAY_REASON ON AWAY_REASON.AWAY_REASON_ID = FN_RAW.AWAY_REASON_ID

INNER JOIN YTD_SUM ON YTD_SUM.STAFF_ID = FN_RAW.STAFF_ID