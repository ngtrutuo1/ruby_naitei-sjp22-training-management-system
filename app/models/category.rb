class Category < ApplicationRecord
  include Positionable

  CATERGORY_PERMITTED_PARAMS = [:name,
  {subject_categories_attributes: [:id, :subject_id, :position,
  :_destroy]}].freeze

  # Associations
  has_many :subject_categories, dependent: :destroy
  has_many :subjects, through: :subject_categories

  accepts_nested_attributes_for :subject_categories, allow_destroy: true

  # Validations
  validates :name, presence: true, uniqueness: {case_sensitive: false},
                  length: {
                    maximum: Settings.category.max_name_length
                  }

  # Scopes
  scope :ordered_by_name, -> {order(:name)}
  scope :recent, -> {order(created_at: :desc)}

  class << self
    def ransackable_attributes _auth_object = nil
      %w(name)
    end

    def ransackable_associations _auth_object = nil
      %w(subject_categories)
    end
  end

  private

  def positionable_association_name
    :subject_categories
  end
end
