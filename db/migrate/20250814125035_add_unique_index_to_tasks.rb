class AddUniqueIndexToTasks < ActiveRecord::Migration[7.0]
  def change
    remove_index :tasks, :name
    
    add_index :tasks, [:name, :taskable_type, :taskable_id], unique: true
  end
end
