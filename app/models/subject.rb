class Subject < ApplicationRecord
  acts_as_paranoid

  # Associations
  has_many :course_subjects # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :user_subjects, through: :course_subjects
  has_many :users, through: :user_subjects

  has_many :courses, through: :course_subjects
  has_many :subject_categories, dependent: :destroy
  has_many :categories, through: :subject_categories
  has_many :tasks, as: :taskable, dependent: :destroy
  has_one_attached :image

  # Validations
  validates :name, presence: true,
            length: {maximum: Settings.subject.max_name_length}
  validates :max_score, presence: true,
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: Settings.subject.max_score_limit
            }
  validates :estimated_time_days, numericality: {greater_than: 0},
            allow_nil: true
  validates :image,
            content_type: {
              in: Settings.subject.allowed_image_types,
              message: :invalid_image_type
            },
            size: {
              less_than: Settings.subject.max_image_size.megabytes,
              message: :image_size_exceeded,
              size: Settings.subject.max_image_size.megabytes
            }

  # Scopes
  scope :ordered_by_name, -> {order(:name)}
  scope :search_by_name, (lambda do |query|
                            if query.present?
                              where("name LIKE ?",
                                    "%#{sanitize_sql_like(query)}%")
                            end
                          end)
end
