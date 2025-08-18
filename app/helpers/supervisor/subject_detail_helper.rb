module Supervisor::SubjectDetailHelper
  def user_tasks_done_subjects_admin user, tasks
    tasks.select {|task| task.user_id == user.id && task.done?}
  end

  def count_process_user_tasks tasks, user
    return Settings.trainee.subjects.default_progress if tasks.blank?

    if tasks.count > Settings.trainee.subjects.min_tasks
      completed_tasks = user_tasks_done_subjects_admin(user, tasks)
      ((completed_tasks.size.to_f / @subject_tasks_count) * Settings.percentage)
        .round
    else
      Settings.trainee.subjects.default_progress
    end
  end
end
