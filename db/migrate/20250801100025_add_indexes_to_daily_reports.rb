class AddIndexesToDailyReports < ActiveRecord::Migration[7.0]
  def change
    add_index :daily_reports, [:user_id, :course_id], if_not_exists: true
  end
end
