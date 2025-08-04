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
  scope :active, -> {where(finished_at: nil)}
  scope :completed, -> {where.not(finished_at: nil)}
  scope :by_user, ->(user) {where(user:)}
  scope :by_subject, ->(subject) {where(subject:)}
  scope :recent, -> {order(started_at: :desc)}
end
