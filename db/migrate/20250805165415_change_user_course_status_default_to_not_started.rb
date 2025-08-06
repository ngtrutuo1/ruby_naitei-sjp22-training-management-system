class ChangeUserCourseStatusDefaultToNotStarted < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_courses, :status, Settings.user_course.status.not_started
  end
end
