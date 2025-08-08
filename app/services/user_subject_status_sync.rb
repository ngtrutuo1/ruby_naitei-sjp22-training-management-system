class UserSubjectStatusSync
  def self.run today: Date.current
    new(today).run
  end

  def initialize today
    @today = today
  end

  def run
    start_subjects
    mark_overdue
    normalize_finished
  end

  private

  def start_subjects
    UserSubject.includes(:course_subject)
               .where(started_at: nil)
               .find_each do |user_subject|
      course_subject = user_subject.course_subject
      next unless course_subject&.start_date && course_subject.finish_date

      if @today.between?(course_subject.start_date, course_subject.finish_date)
        user_subject.update_columns(
          started_at: @today,
          status: UserSubject.statuses[:in_progress]
        )
      elsif @today > course_subject.finish_date
        user_subject.update_columns(
          status: UserSubject.statuses[:overdue_and_not_finished]
        )
      end
    end
  end

  def mark_overdue
    UserSubject.includes(:course_subject)
               .where(completed_at: nil)
               .find_each do |user_subject|
      course_subject = user_subject.course_subject
      next unless course_subject&.finish_date
      next unless @today > course_subject.finish_date

      user_subject.update_columns(
        status: UserSubject.statuses[:overdue_and_not_finished]
      )
    end
  end

  def normalize_finished
    UserSubject.includes(:course_subject)
               .where.not(completed_at: nil)
               .find_each do |user_subject|
      course_subject = user_subject.course_subject
      next unless course_subject&.finish_date

      completion_date = user_subject.completed_at.to_date
      deadline = course_subject.finish_date

      new_status = if completion_date < deadline
                     :finished_early
                   elsif completion_date == deadline
                     :finished_ontime
                   else
                     :finished_but_overdue
                   end

      user_subject.update_columns(
        status: UserSubject.statuses[new_status]
      )
    end
  end
end
