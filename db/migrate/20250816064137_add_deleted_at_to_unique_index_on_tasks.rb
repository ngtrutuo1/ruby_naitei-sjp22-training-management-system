class AddDeletedAtToUniqueIndexOnTasks < ActiveRecord::Migration[6.0]
  def change
    remove_index :tasks, name: "index_tasks_on_name_and_taskable_type_and_taskable_id", if_exists: true

    add_index :tasks, [:name, :taskable_type, :taskable_id, :deleted_at],
              unique: true,
              name: "idx_tasks_on_name_type_id_and_deleted_at"
  end
end
