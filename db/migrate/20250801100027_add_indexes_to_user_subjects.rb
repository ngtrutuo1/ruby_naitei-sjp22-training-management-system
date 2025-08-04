class AddIndexesToUserSubjects < ActiveRecord::Migration[7.0]
  def change
    add_index :user_subjects, [:user_course_id, :course_subject_id, :user_id], unique: true, if_not_exists: true, name: "idx_us_on_ucid_csid_uid"
  end
end
