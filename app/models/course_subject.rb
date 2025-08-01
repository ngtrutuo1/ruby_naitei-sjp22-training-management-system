class CourseSubject < ApplicationRecord
  # Associations
  belongs_to :course
  belongs_to :subject
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :user_subjects, dependent: :destroy

  # Validations
  validates :course_id, uniqueness: {scope: :subject_id}
  validates :position,
            numericality: {
              greater_than_or_equal_to: Settings.course_subject.min_position
            },
            allow_nil: true
  validate :finish_date_after_start_date

  # Scopes
  scope :ordered_by_position, -> {order(:position)}
  scope :by_course, ->(course) {where(course:)}
  scope :by_subject, ->(subject) {where(subject:)}

  private

  def finish_date_after_start_date
    return unless start_date && finish_date

    return unless finish_date < start_date

    errors.add(:finish_date,
               I18n.t("error_messages.finish_date_after_start_date"))
  end
end
