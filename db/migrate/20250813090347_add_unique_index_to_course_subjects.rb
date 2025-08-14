class AddUniqueIndexToCourseSubjects < ActiveRecord::Migration[7.0]
  def change
    add_index :course_subjects, [:course_id, :position], unique: true
  end
end
