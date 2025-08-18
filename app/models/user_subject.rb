class UserSubject < ApplicationRecord
  # Enums
  enum status: {not_started: Settings.user_subject.status.not_started,
                in_progress: Settings.user_subject.status.in_progress,
                finished_early: Settings.user_subject.status.finished_early,
                finished_ontime: Settings.user_subject.status.finished_ontime,
                finished_but_overdue: Settings.user_subject.status
                                              .finished_but_overdue,
                overdue_and_not_finished: Settings.user_subject.status
                                                  .overdue_and_not_finished}
  # Associations
  belongs_to :user
  belongs_to :user_course
  belongs_to :course_subject
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :user_tasks, dependent: :destroy

  # Validations
  validates :user_id,
            uniqueness: {scope: [:course_subject_id, :user_course_id]}
  validates :score,
            numericality: {
              greater_than_or_equal_to: Settings.user_subject.min_score,
              less_than_or_equal_to: Settings.user_subject.max_score
            },
              allow_nil: true

  # Scopes
  scope :active, -> {where(completed_at: nil)}
  scope :completed, -> {where.not(completed_at: nil)}
  scope :for_course, (lambda do |course|
    joins(:course_subject).where(course_subject: {course:})
  end)
  scope :by_user, ->(user) {where(user:)}
  scope :by_subject, ->(subject) {where(subject:)}
  scope :recent, -> {order(started_at: :desc)}

  def display_status
    # Infer status from course_subject dates if not explicitly started
    return inferred_status_from_schedule unless started_at

    if completed_at
      determine_finished_status
    elsif overdue?
      Settings.user_subject.display_status.overdue_and_not_finished
    else
      Settings.user_subject.display_status.in_progress
    end
  end

  def overdue?
    return false unless course_subject.finish_date

    Date.current > course_subject.finish_date
  end

  def comment_count
    comments.size
  end

  # Compute enum symbol for finished status based on completed_at vs deadline
  def compute_finish_status completed_date
    deadline = course_subject&.finish_date
    return :finished_ontime unless deadline && completed_date

    completion = completed_date.to_date
    return :finished_early if completion < deadline
    return :finished_ontime if completion == deadline

    :finished_but_overdue
  end

  private

  def determine_finished_status
    return finished_ontime_status unless course_subject.finish_date

    compare_completion_with_deadline
  end

  def finished_ontime_status
    Settings.user_subject.display_status.finished_ontime
  end

  def compare_completion_with_deadline
    completion_date = completed_at.to_date
    deadline = course_subject.finish_date

    if completion_date < deadline
      Settings.user_subject.display_status.finished_early
    elsif completion_date == deadline
      Settings.user_subject.display_status.finished_ontime
    else
      Settings.user_subject.display_status.finished_but_overdue
    end
  end

  def inferred_status_from_schedule
    start_date = course_subject.start_date
    finish_date = course_subject.finish_date

    # Without dates we cannot infer; treat as not started
    unless start_date && finish_date
      return Settings.user_subject.display_status.not_started
    end

    if Date.current > finish_date
      return Settings.user_subject.display_status.overdue_and_not_finished
    end
    if Date.current.between?(start_date, finish_date)
      return Settings.user_subject.display_status.in_progress
    end

    Settings.user_subject.display_status.not_started
  end
end
