module CoursesHelper
  SUBJECT_NON_DELETABLE_STATUSES = %w(in_progress finished).freeze
  FINISHED_ONTIME_STATUS = UserSubject.statuses[:finished_ontime]
  FINISHED_STATUS_VALUES = UserSubject.statuses.values_at(
    :finished_early, :finished_ontime, :finished_but_overdue
  )

  def course_status_badge status
    status_text = t("activerecord.attributes.course.statuses.#{status}",
                    default: status.humanize)

    css_class = case status
                when "not_started" then "label label-default"
                when "in_progress" then "label label-success"
                when "finished"    then "label label-primary"
                else "label label-info"
                end

    content_tag(:span, status_text, class: css_class)
  end

  def course_link_url_for course
    if admin_role? || supervisor_role?
      supervisor_course_url(course)
    else
      trainee_course_url(course)
    end
  end

  def course_members_path_for course
    if admin_role? || supervisor_role?
      members_supervisor_course_path(course)
    else
      members_trainee_course_path(course)
    end
  end

  def course_subjects_path_for course
    if admin_role? || supervisor_role?
      subjects_supervisor_course_path(course)
    else
      subjects_trainee_course_path(course)
    end
  end

  def destroy_user_course_path_for course, user_course_id:
    supervisor_course_user_course_path(course, id: user_course_id)
  end

  def destroy_supervisor_path_for course, supervisor_id:
    supervisor_course_supervisor_path(course, id: supervisor_id)
  end

  def finish_course_subject_path_for course, course_subject_id:
    finish_supervisor_course_course_subject_path(course, id: course_subject_id)
  end

  def destroy_course_subject_path_for course, course_subject_id:
    supervisor_course_course_subject_path(course, id: course_subject_id)
  end

  def can_leave_course? course
    supervisor_role? &&
      course.supervisors.include?(current_user) &&
      course.supervisors.count > 1
  end

  def leave_course_path_for course
    supervisor_course_supervisor_path(course, id: current_user.id)
  end

  def subject_status course_subject
    return Settings.subject_status.finished if subject_finished?(course_subject)
    if subject_in_progress?(course_subject)
      return Settings.subject_status.in_progress
    end

    Settings.subject_status.not_started
  end

  private

  def subject_finished? course_subject
    past_finish_date?(course_subject) || all_trainees_finished?(course_subject)
  end

  def subject_in_progress? course_subject
    course_subject.start_date && course_subject.start_date <= Date.current
  end

  def past_finish_date? course_subject
    course_subject.finish_date && course_subject.finish_date < Date.current
  end

  def all_trainees_finished? course_subject
    if course_subject.association(:user_subjects).loaded?
      course_subject.user_subjects.none? do |user_subject|
        FINISHED_STATUS_VALUES.exclude?(user_subject.status_before_type_cast)
      end
    else
      course_subject.user_subjects
                    .where.not(status: FINISHED_STATUS_VALUES)
                    .none?
    end
  end
end
