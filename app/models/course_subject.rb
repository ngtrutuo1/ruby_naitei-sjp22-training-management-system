class CourseSubject < ApplicationRecord
  # Associations
  belongs_to :course
  belongs_to :subject
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :user_subjects, dependent: :destroy

  # Validations
  validates :course_id, uniqueness: {scope: :subject_id}
  validates :position, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Settings.course_subject.min_position,
              allow_blank: true
            }
  validate :finish_date_after_start_date
  validates :position, uniqueness: {scope: :course_id}

  # Scopes
  scope :ordered_by_position, -> {order(:position)}
  scope :by_course, ->(course) {where(course:)}
  scope :by_subject, ->(subject) {where(subject:)}

  private

  def finish_date_after_start_date
    return unless start_date && finish_date

    return unless finish_date < start_date

    errors.add(:finish_date,
               :finish_date_after_start_date)
  end
end
