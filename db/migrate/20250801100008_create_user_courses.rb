class CreateUserCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :user_courses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :joined_at
      t.datetime :finished_at
      t.integer :status, default: Settings.user_course.status.new
      t.timestamps
    end
  end
end
