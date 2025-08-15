class SubjectCategory < ApplicationRecord
  # Associations
  belongs_to :subject
  belongs_to :category

  # Validations
  validates :subject_id, uniqueness: {scope: :category_id}
  validates :position, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Settings.course_subject.min_position,
              allow_blank: true
            }

  # Scopes
  scope :ordered_by_position, -> {order(:position)}
  scope :by_subject, ->(subject) {where(subject:)}
  scope :by_category, ->(category) {where(category:)}
end
