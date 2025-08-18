class ChangeIndexOnCourseSubjectsPosition < ActiveRecord::Migration[7.0]
  def change
    if index_exists?(:course_subjects, [:course_id, :position], name: "index_course_subjects_on_course_id_and_position")
      remove_index :course_subjects, name: "index_course_subjects_on_course_id_and_position"
    end

    add_index :course_subjects, [:course_id, :position], name: "idx_course_subjects_course_id_position"
  end
end
