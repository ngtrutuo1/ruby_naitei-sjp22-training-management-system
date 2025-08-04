class AddIndexesToTasks < ActiveRecord::Migration[7.0]
  def change
    add_index :tasks, [:taskable_type, :taskable_id], if_not_exists: true
  end
end
