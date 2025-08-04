class AddIndexesToCourses < ActiveRecord::Migration[7.0]
  def change
    add_index :courses, :user_id, if_not_exists: true
  end
end
