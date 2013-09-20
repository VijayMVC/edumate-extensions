SELECT
  CARER.CARER_NUMBER AS "LOOKUP_CODE",
  CONTACT.FIRSTNAME,
  CONTACT.SURNAME,
  ALUMNI.FORM_RUN_INFO

FROM TABLE(EDUMATE.GETCURRCARERCONTACTINFO(CURRENT DATE, null)) CARERS

INNER JOIN CONTACT ON CONTACT.CONTACT_ID = CARERS.CONTACT_ID
LEFT JOIN TABLE(EDUMATE.GETALLSTUDENTSTATUS(CURRENT DATE)) ALUMNI ON ALUMNI.CONTACT_ID = CARERS.CONTACT_ID AND ALUMNI.STUDENT_STATUS_ID IN (2,3)
INNER JOIN CARER ON CARER.CONTACT_ID = CARERS.CONTACT_ID

WHERE
  CARERS.DECEASED_FLAG IS NULL
  AND
  ALUMNI.FORM_RUN_INFO IS NOT NULL

ORDER BY ALUMNI.FORM_RUN_INFO, CONTACT.SURNAME