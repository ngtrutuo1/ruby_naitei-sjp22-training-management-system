class AddDeletedAtToSubject < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :deleted_at, :datetime
    add_index :subjects, :deleted_at
  end
end
