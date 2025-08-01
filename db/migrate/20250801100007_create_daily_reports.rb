class CreateDailyReports < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.text :content
      t.integer :status, default: Settings.daily_report.status.draft
      t.timestamps
    end
  end
end
