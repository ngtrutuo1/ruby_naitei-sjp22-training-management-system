class Task < ApplicationRecord
  acts_as_paranoid

  TASK_PERMITTED_PARAMS = %i(name taskable_id taskable_type subject_id).freeze
  TASKABLE_SCOPE = %i(taskable_id taskable_type).freeze

  # Associations
  belongs_to :taskable, -> {with_deleted}, polymorphic: true
  has_many :user_tasks # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :users, through: :user_tasks

  # Validations
  validates :name, presence: true,
            length: {maximum: Settings.task.max_name_length},
            uniqueness: {case_sensitive: false,
                         scope: %i(taskable_type taskable_id deleted_at)}

  delegate :name, to: :taskable, prefix: true

  # Callbacks
  after_create :create_user_tasks_for_existing_trainees,
               if: :course_subject_task?

  # Scopes
  scope :ordered_by_name, -> {order(:name)}
  scope :for_taskable_type, ->(type) {where(taskable_type: type)}
  scope :search_by_name, (lambda do |query|
                            if query.present?
                              where("name LIKE ?",
                                    "%#{sanitize_sql_like(query)}%")
                            end
                          end)
  scope :recent, -> {order(created_at: :desc)}
  scope :by_subject, (lambda do |taskable_id|
    if taskable_id.present?
      where(taskable_type: Subject.name, taskable_id: taskable_id)
    end
  end)

  private

  def course_subject_task?
    taskable_type == Settings.task.taskable_type.course_subject
  end

  def create_user_tasks_for_existing_trainees
    return unless course_subject_task?

    course_subject = taskable
    course_subject.user_subjects.includes(:user).find_each do |user_subject|
      next unless user_subject.user.trainee?

      # Create user_task for this task
      user_subject.user_tasks.create!(
        user: user_subject.user,
        task: self,
        status: Settings.user_task.status.not_done
      )
    end
  end
end
