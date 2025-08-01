class DailyReport < ApplicationRecord
  # Enums
  enum is_done: {draft: Settings.daily_report.status.draft,
                 submitted: Settings.daily_report.status.submitted}

  # Associations
  belongs_to :user
  belongs_to :course

  # Validations
  validates :content,
            length: {maximum: Settings.daily_report.max_content_length}

  # Scopes
  scope :completed, -> {where(is_done: true)}
  scope :pending, -> {where(is_done: false)}
  scope :recent, -> {order(created_at: :desc)}
  scope :by_user, ->(user) {where(user:)}
  scope :by_course, ->(course) {where(course:)}
end
