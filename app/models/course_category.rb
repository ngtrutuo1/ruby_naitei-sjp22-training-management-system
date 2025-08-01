class CourseCategory < ApplicationRecord
  # Associations
  belongs_to :course
  belongs_to :category

  # Validations
  validates :course_id, uniqueness: {scope: :category_id}

  # Scopes
  scope :by_course, ->(course) {where(course:)}
  scope :by_category, ->(category) {where(category:)}
end
