class Category < ApplicationRecord
  # Associations
  has_many :subject_categories, dependent: :destroy
  has_many :subjects, through: :subject_categories

  # Validations
  validates :name, presence: true,
                  length: {
                    maximum: Settings.category.max_name_length
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
