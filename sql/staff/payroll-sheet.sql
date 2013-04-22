SELECT
	CONTACT.SURNAME,
	CONTACT.FIRSTNAME,
	AWAY_REASON.AWAY_REASON,
	FROM_DATE,
	TO_DATE,
	COMMENT,
	FORM_REQUIRED,
	FORM_SUBMITTED

FROM STAFF_AWAY SA

INNER JOIN STAFF ON SA.STAFF_ID = STAFF.STAFF_ID
INNER JOIN CONTACT ON STAFF.CONTACT_ID = CONTACT.CONTACT_ID
INNER JOIN AWAY_REASON ON SA.AWAY_REASON_ID = AWAY_REASON.AWAY_REASON_ID

WHERE
	FROM_DATE >= (CURRENT_DATE - 14 DAYS)
		AND
	TO_DATE <= (CURRENT_DATE)
	
ORDER BY SURNAME