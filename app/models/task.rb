class Task < ApplicationRecord
  # Associations
  belongs_to :taskable, polymorphic: true
  has_many :user_tasks, dependent: :destroy
  has_many :users, through: :user_tasks

  # Validations
  validates :name, presence: true,
length: {maximum: Settings.task.max_name_length}

  # Scopes
  scope :ordered_by_name, -> {order(:name)}
  scope :for_taskable, ->(taskable) {where(taskable:)}
end
