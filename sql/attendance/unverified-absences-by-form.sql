-- Unverified Absences by Form (Modified)

-- This is a fork of Edumate's 'Unverified Absences by Tutor' report.
-- It allows the user to extract the unverified absence data for a single form.

WITH student_tutor_class AS
    (
    SELECT
        view_student_class_enrolment.student_id, 
        view_student_class_enrolment.class_id,
        view_student_class_enrolment.class,
        contact.contact_id,
        contact.firstname,
        contact.surname,
        form,
        ROW_NUMBER() OVER (PARTITION BY view_student_class_enrolment.student_id ORDER BY class_teacher.is_primary DESC, view_student_class_enrolment.start_date DESC)
    FROM view_student_class_enrolment

    INNER JOIN student on view_student_class_enrolment.student_id=student.student_id
    INNER JOIN table(edumate.get_enroled_students_form_run ('[[From Date=date]]')) gesfr on student.student_id=gesfr.student_id
    INNER JOIN form_run on gesfr.form_run_id=form_run.form_run_id
    INNER JOIN form on form_run.form_id=form.form_id 

    INNER JOIN class_teacher ON class_teacher.class_id = view_student_class_enrolment.class_id
    INNER JOIN teacher ON teacher.teacher_id = class_teacher.teacher_id
    INNER JOIN contact ON contact.contact_id = teacher.contact_id
    WHERE view_student_class_enrolment.class_type_id = 2
        AND view_student_class_enrolment.start_date <= '[[From Date=date]]'
        AND view_student_class_enrolment.end_date >= '[[To Date=date]]' -- lets take tutor as at last date
    ),

    student_unverifieds AS
    (
    SELECT
        student_tutor_class.class,
        student_tutor_class.form,
        student_tutor_class.firstname||''||student_tutor_class.surname||
            (CASE WHEN student_tutor_class2.contact_id is not null AND student_tutor_class.contact_id != student_tutor_class2.contact_id 
                THEN '&'||student_tutor_class2.firstname||''||student_tutor_class2.surname ELSE '' END) AS "TUTOR",
        student.student_number,
        contact.firstname,
        contact.surname,
        daily_attendance.date_on,
        daily_attendance_status.daily_attendance_status AS "DAILY_STATUS",
        period.short_name AS "PERIOD",
        attend_status.attend_status,
        COALESCE(absence_reason.absence_reason,'') AS "REASON",
        (CASE WHEN absence_verification.absence_verification is null OR absence_verification.absence_verification_id = 1 THEN '' ELSE absence_verification.absence_verification END) AS "VERIFICATION",
        ROW_NUMBER() OVER (PARTITION BY student.student_id, daily_attendance.date_on ORDER BY period.start_time)
    FROM daily_attendance
    INNER JOIN daily_attendance_status ON daily_attendance_status.daily_attendance_status_id = daily_attendance.daily_attendance_status_id
    INNER JOIN attendance ON attendance.student_id = daily_attendance.student_id
    INNER JOIN lesson ON lesson.lesson_id = attendance.lesson_id 
        AND lesson.date_on = daily_attendance.date_on
    INNER JOIN attend_status ON attend_status.attend_status_id = attendance.attend_status_id
    INNER JOIN period_class ON period_class.period_class_id = lesson.period_class_id
    INNER JOIN period_cycle_day ON period_cycle_day.period_cycle_day_id = period_class.period_cycle_day_id
    INNER JOIN period ON period.period_id = period_cycle_day.period_id 
    INNER JOIN student ON student.student_id = daily_attendance.student_id
    INNER JOIN contact ON contact.contact_id = student.contact_id
    -- get tutor(s)
    LEFT JOIN student_tutor_class ON student_tutor_class.student_id = student.student_id
        AND student_tutor_class.rownum = 1
    LEFT JOIN student_tutor_class student_tutor_class2 ON student_tutor_class2.student_id = student.student_id
        AND student_tutor_class2.rownum = 2
        AND student_tutor_class2.class_id = student_tutor_class.class_id -- only get a 2nd teacher for same class, not another tutor group
    -- get absentee reason
    LEFT JOIN absentee_reason ON absentee_reason.student_id = student.student_id 
        AND absentee_reason.effective_start <= TIMESTAMP(daily_attendance.date_on, period.end_time) 
        AND absentee_reason.effective_end >= TIMESTAMP(daily_attendance.date_on, period.start_time)
    LEFT JOIN absence_reason ON absence_reason.absence_reason_id = absentee_reason.absence_reason_id
    LEFT JOIN absence_verification ON absence_verification.absence_verification_id = absentee_reason.absence_verification_id
    WHERE daily_attendance.daily_attendance_status_id in (2,3,7,8,11,13,14,15) 
        AND daily_attendance.date_on BETWEEN '[[From Date=date]]' AND '[[To Date=date]]'
    )

SELECT
    TO_CHAR(DATE('[[From Date=date]]'),'DD/MM/YY')||' - '||TO_CHAR(DATE('[[To Date=date]]'),'DD/MM/YY') AS "HEADING",
    COALESCE(class,'')||' - '||COALESCE(tutor,'') AS "TUTOR_GROUP",
    (CASE WHEN rownum = 1 THEN student_number ELSE '' END) AS "STUDENT",
    (CASE WHEN rownum = 1 THEN firstname ELSE '' END) AS "FIRSTNAME",
    (CASE WHEN rownum = 1 THEN surname||'<br>'||class ELSE '' END) AS "SURNAME",
    (CASE WHEN rownum = 1 THEN TO_CHAR(date_on,'DD/MM') ELSE '' END) AS "WHEN",
    (CASE WHEN rownum = 1 THEN class ELSE '' END) AS "tutor_group",
    form,
    period,
    attend_status,
    reason,
    verification
FROM student_unverifieds
WHERE period like '%[[Period=query_list(SELECT DISTINCT period FROM period)]]%' AND form LIKE '[[Form=table_list(form.form)]]' 
ORDER BY form, tutor_group, student_unverifieds.surname, student_unverifieds.firstname, student_unverifieds.date_on, student_unverifieds.rownum