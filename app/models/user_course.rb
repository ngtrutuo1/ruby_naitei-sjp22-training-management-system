class UserCourse < ApplicationRecord
  # Enums
  enum status: {not_started: Settings.user_course.status.not_started,
                in_progress: Settings.user_course.status.in_progress,
                finished: Settings.user_course.status.finished}
  # Associations
  belongs_to :user
  belongs_to :course
  has_many :user_subjects, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  # Validations
  validates :user_id, uniqueness: {scope: :course_id}

  # Scopes
  scope :active, -> {where(finished_at: nil)}
  scope :completed, -> {where.not(finished_at: nil)}
  scope :by_user, ->(user) {where(user:)}
  scope :by_course, ->(course) {where(course:)}
  scope :recent, -> {order(joined_at: :desc)}
end
