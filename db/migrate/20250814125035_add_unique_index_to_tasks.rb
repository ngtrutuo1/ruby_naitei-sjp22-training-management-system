class AddUniqueIndexToTasks < ActiveRecord::Migration[7.0]
  def change
    add_index :tasks, [:name, :taskable_type, :taskable_id], unique: true
  end
end
