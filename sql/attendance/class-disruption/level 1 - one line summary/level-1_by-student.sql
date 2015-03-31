WITH report_vars AS (
  SELECT
    --(SELECT start_date FROM term WHERE term = 'Term 1' AND YEAR(start_date) = YEAR(current date) FETCH FIRST 1 ROW ONLY) AS "REPORT_START",
    (current date - 11 DAYS) AS "REPORT_START",
    (current date) AS "REPORT_END"

  FROM SYSIBM.sysdummy1
),

date_range(date_on) AS (
  SELECT (SELECT report_start FROM report_vars) AS DATE_ON FROM SYSIBM.SYSDUMMY1
  UNION ALL
  SELECT date_on + 1 DAY AS DATE_ON FROM date_range
  WHERE date_on < (SELECT report_end FROM report_vars)
),

timetabled_dates AS (
  SELECT
    date_range.date_on,
    timetable.timetable_id,
    edumate.getdayindex(term.start_date,term.cycle_start_day,cycle.days_in_cycle, date_range.date_on) AS DAY_INDEX,
    cycle.cycle_id
  
  FROM date_range
  
  INNER JOIN term ON date_range.date_on BETWEEN term.start_date AND term.end_date
  INNER JOIN term_group ON term_group.term_id = term.term_id
  INNER JOIN cycle ON cycle.cycle_id = term_group.cycle_id
  INNER JOIN timetable ON timetable.timetable_id = term.timetable_id
),

student_homeroom AS (
  SELECT
    vsce.student_id,
    vsce.class AS HOMEROOM,
    ROW_NUMBER() OVER (PARTITION BY vsce.student_id ORDER BY vsce.end_date DESC, vsce.start_date DESC) AS ROW_NUM
  
  FROM view_student_class_enrolment vsce
  
  WHERE vsce.class_type_id = 2 AND current_date BETWEEN vsce.start_date AND vsce.end_date
),

student_form AS (
  SELECT
    student_form_run.student_id,
    form.short_name AS FORM,
    form_run.form_run AS FORM_RUN,
    ROW_NUMBER() OVER (PARTITION BY student_form_run.student_id ORDER BY student_form_run.end_date DESC) AS ROW_NUM
  FROM student_form_run 
  
  INNER JOIN form_run ON form_run.form_run_id = student_form_run.form_run_id
  INNER JOIN form ON form.form_id = form_run.form_id
  
  WHERE current_date BETWEEN student_form_run.start_date AND student_form_run.end_date
),

students_on_event AS (
  SELECT DISTINCT
    event_student.student_id,
    event.start_date,
    event.end_date

  FROM event

  INNER JOIN event_student ON event_student.event_id = event.event_id

  WHERE
    DATE(event.start_date) <= (SELECT report_end FROM report_vars)
    AND
    DATE(event.end_date) >= (SELECT report_start FROM report_vars)
    AND
    (event.permission_flag is null OR event.permission_flag = 0 OR event_student.permission_flag = 1)
),

student_appointments AS (
  SELECT DISTINCT
    student.student_id,
    activity.start_date,
    activity.end_date

  FROM activity

  INNER JOIN activity_contact ON activity_contact.activity_id = activity.activity_id
  INNER JOIN student ON student.contact_id = activity_contact.contact_id
  
  WHERE
    DATE(activity.start_date) <= (SELECT report_end FROM report_vars)
    AND
    DATE(activity.end_date) >= (SELECT report_start FROM report_vars)
),
      
staff_on_event AS (
  SELECT
    event_staff.staff_id,
    event.start_date,
    event.end_date
  
  FROM event
  
  INNER JOIN event_staff ON event_staff.event_id = event.event_id
  
  WHERE
    DATE(event.start_date) <= (SELECT report_end FROM report_vars)
    AND
    DATE(event.end_date) >= (SELECT report_start FROM report_vars)
),

raw_data AS (
  SELECT
    timetabled_dates.date_on,
    period.short_name AS PERIOD,
    class.class_id,
    class.course_id,
    class.class,
    teacher.contact_id,
    view_student_class_enrolment.student_id,
    -- flag is student is in class
    1 AS PERIODS,
    CASE WHEN students_on_event.student_id is null AND perd_cls_replace.perd_cls_replace_id is null THEN 1 ELSE 0 END AS TO_ATTEND,
    CASE WHEN students_on_event.student_id is null AND perd_cls_replace.perd_cls_replace_id is null 
        AND student_appointments.student_id is null AND attend_status.attend_status_id = 3 THEN 1 ELSE 0 END AS ABSENT,
    CASE WHEN students_on_event.student_id is not null THEN 1 ELSE 0 END AS ON_EVENT,
    CASE WHEN student_appointments.student_id is not null OR attend_status.attend_status_id IN (18,19,20) THEN 1 ELSE 0 END AS APPOINTMENT,
    CASE WHEN staff_on_event.staff_id is not null THEN 1 ELSE 0 END AS STAFF_EVENT,
    CASE WHEN away_reason.away_reason_id IN (1,3,8,10,75,97,98,121,146,169) THEN 1 ELSE 0 END AS STAFF_PERSONAL,
    CASE WHEN away_reason.away_reason_id is not null AND away_reason.away_reason_id IN (5,6,9,25,49,73,74) THEN 1 ELSE 0 END AS STAFF_OTHER
  
  FROM timetabled_dates

  INNER JOIN cycle_day ON cycle_day.cycle_id = timetabled_dates.cycle_id AND cycle_day.day_index = timetabled_dates.day_index
  INNER JOIN period_cycle_day ON period_cycle_day.cycle_day_id = cycle_day.cycle_day_id
  INNER JOIN period ON period.period_id = period_cycle_day.period_id
  INNER JOIN period_class ON period_class.period_cycle_day_id = period_cycle_day.period_cycle_day_id
    AND timetabled_dates.date_on BETWEEN period_class.effective_start AND period_class.effective_end 
    AND period_class.timetable_id = timetabled_dates.timetable_id

  INNER JOIN class ON class.class_id = period_class.class_id
    AND class.class_type_id IN (1,9,10,1101,1124,1148)
  INNER JOIN perd_cls_teacher ON perd_cls_teacher.period_class_id = period_class.period_class_id
  INNER JOIN teacher ON teacher.teacher_id = perd_cls_teacher.teacher_id
  INNER JOIN staff ON staff.contact_id = teacher.contact_id

  -- get replacement teacher (cause??) event / away
  -- check if staff member is on event
  LEFT JOIN staff_on_event ON staff_on_event.staff_id = staff.staff_id
    AND staff_on_event.start_date <= TIMESTAMP(timetabled_dates.date_on,period.end_time)
    AND staff_on_event.end_date >= TIMESTAMP(timetabled_dates.date_on,period.start_time)
  -- check if staff is away
  LEFT JOIN staff_away ON staff_away.staff_id = staff.staff_id
    AND staff_away.from_date <= TIMESTAMP(timetabled_dates.date_on,period.end_time)
    AND staff_away.to_date >= TIMESTAMP(timetabled_dates.date_on,period.start_time)
  LEFT JOIN away_reason ON away_reason.away_reason_id = staff_away.away_reason_id
  -- check for a replacement
  LEFT JOIN perd_cls_replace ON perd_cls_replace.period_class_id = period_class.period_class_id
    AND perd_cls_replace.from_date <= timetabled_dates.date_on
    AND perd_cls_replace.to_date >= timetabled_dates.date_on
  -- check for combined class
  LEFT JOIN class as combinedClasses on combinedClasses.class_id = perd_cls_replace.class_id
  -- class must have students
  INNER JOIN view_student_class_enrolment ON view_student_class_enrolment.class_id = period_class.class_id
    AND view_student_class_enrolment.start_date <= timetabled_dates.date_on
    AND view_student_class_enrolment.end_date >= timetabled_dates.date_on   
  -- is student on event?
  LEFT JOIN students_on_event ON students_on_event.student_id = view_student_class_enrolment.student_id
    AND students_on_event.start_date <= TIMESTAMP(timetabled_dates.date_on,period.end_time)
    AND students_on_event.end_date >= TIMESTAMP(timetabled_dates.date_on,period.start_time)
  -- attend status of student
  LEFT JOIN lesson ON lesson.period_class_id = period_class.period_class_id
    AND lesson.date_on = timetabled_dates.date_on
  LEFT JOIN attendance ON attendance.lesson_id = lesson.lesson_id
    AND attendance.student_id = view_student_class_enrolment.student_id
  LEFT JOIN attend_status ON attend_status.attend_status_id = attendance.attend_status_id
  -- student appointment
  LEFT JOIN student_appointments ON student_appointments.student_id = view_student_class_enrolment.student_id
    AND student_appointments.start_date <= TIMESTAMP(timetabled_dates.date_on,period.end_time)
    AND student_appointments.end_date >= TIMESTAMP(timetabled_dates.date_on,period.start_time)
),

student_class_stats AS (
  SELECT
    student_id,
    FLOAT(SUM(periods)) AS PERIODS,
    FLOAT(SUM(to_attend)) AS TO_ATTEND,

    FLOAT(SUM(absent)) AS ABSENT,
    FLOAT(SUM(on_event)) AS ON_EVENT,
    FLOAT(SUM(appointment)) AS APPOINTMENT,
    FLOAT(SUM(absent) + SUM(on_event) + SUM(appointment)) AS STUDENT_TOTAL,

    FLOAT(SUM(staff_event)) AS STAFF_EVENT,
    FLOAT(SUM(staff_personal)) AS STAFF_PERSONAL,
    FLOAT(SUM(staff_other)) AS STAFF_OTHER,
    FLOAT(SUM(staff_event) + SUM(staff_personal) + SUM(staff_other)) AS STAFF_TOTAL,

    FLOAT(SUM(to_attend-absent)) AS ATTENDED

  FROM raw_data

  GROUP BY student_id
),

overall_student_stats AS
(
  SELECT
    student_id,
    FLOAT(SUM(to_attend))*100/COUNT(to_attend) AS TO_ATTEND,
    FLOAT(SUM(absent))*100/COUNT(absent) AS ABSENT,
    FLOAT(SUM(on_event))*100/COUNT(on_event) AS ON_EVENT,
    FLOAT(SUM(appointment))*100/COUNT(appointment) AS APPOINTMENT,
    FLOAT(SUM(staff_event))*100/COUNT(staff_event) AS STAFF_EVENT,
    FLOAT(SUM(staff_personal))*100/COUNT(staff_personal) AS STAFF_PERSONAL,
    FLOAT(SUM(staff_other))*100/COUNT(staff_other) AS STAFF_OTHER,
    FLOAT(SUM(to_attend-absent)) AS ATTENDED
  
  FROM raw_data
  GROUP BY student_id
),

period_counts AS (
  SELECT DISTINCT date_on, period, class_id, student_id
  FROM raw_data
),

scheduled_periods AS (
  SELECT student_id, COUNT(student_id) AS "PERIODS"
  FROM period_counts
  GROUP BY student_id
),

class_students AS (
  SELECT
    UPPER(contact.surname)||', '||COALESCE(contact.preferred_name,contact.firstname) AS STUDENT_NAME,
    (CASE WHEN student_homeroom.homeroom IS null THEN ('*** Left: ' || TO_CHAR(gass.end_date, 'DD Mon, YYYY')) ELSE student_homeroom.homeroom END) AS "HOMEROOM",
    --scheduled_periods.periods AS "SCHEDULED_PERIODS",
    TO_CHAR(periods,'9990.0') AS PERIODS,
    TO_CHAR(to_attend,'990.9')||'%' AS TO_ATTEND,
    TO_CHAR(absent,'990.9')||'%' AS ABSENT,
    TO_CHAR(on_event,'990.9')||'%' AS ON_EVENT,
    TO_CHAR(appointment,'990.9')||'%' AS APPOINTMENT,
    TO_CHAR(FLOAT((absent) + (on_event) + (appointment)), '990.9')||'%' AS STUDENT_TOTAL,
    
    TO_CHAR(staff_event,'990.9')||'%' AS STAFF_EVENT,
    TO_CHAR(staff_other,'990.9')||'%' AS STAFF_OTHER,
    TO_CHAR(staff_personal,'990.9')||'%' AS STAFF_PERSONAL,
    TO_CHAR(FLOAT((staff_event) + (staff_other) + (staff_personal)), '990.9')||'%' AS STAFF_TOTAL,

    TO_CHAR(to_attend-absent,'990.9')||'%' AS ATTENDED

  FROM overall_student_stats

  INNER JOIN student ON student.student_id = overall_student_stats.student_id
  INNER JOIN contact ON contact.contact_id = student.contact_id
  LEFT JOIN student_homeroom ON student_homeroom.student_id = student.student_id AND student_homeroom.row_num = 1
  LEFT JOIN TABLE(EDUMATE.getallstudentstatus(current date)) gass ON gass.student_id = overall_student_stats.student_id
  LEFT JOIN scheduled_periods ON scheduled_periods.student_id = overall_student_stats.student_id
)

SELECT
  TO_CHAR((SELECT report_start FROM report_vars),'DD Month YYYY') || ' to ' || TO_CHAR((SELECT report_end FROM report_vars),'DD Month YYYY')AS "REPORT_SCOPE",
  student_name,
  REPLACE(homeroom, ' Home Room ', ' ') AS "HOMEROOM",
  periods,
  ((SELECT BUSINESS_DAYS_COUNT FROM TABLE(DB2INST1.BUSINESS_DAYS_COUNT((SELECT report_start FROM report_vars), (SELECT report_end FROM report_vars)))) * 6) AS "MAX_PERIODS",
  absent,
  on_event,
  appointment,
  student_total,
  staff_event,
  staff_other,
  staff_personal,
  staff_total,
  attended

FROM class_students

ORDER BY student_name