class AddIndexesToCourseSubjects < ActiveRecord::Migration[7.0]
  def change
    add_index :course_subjects, [:course_id, :subject_id], unique: true, if_not_exists: true
  end
end
