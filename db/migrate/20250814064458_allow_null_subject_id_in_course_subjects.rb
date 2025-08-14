class AllowNullSubjectIdInCourseSubjects < ActiveRecord::Migration[7.0]
  def change
    change_column_null :course_subjects, :subject_id, true
  end
end
