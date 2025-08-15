class AddUniqueIndexToNames < ActiveRecord::Migration[7.0]
  def change
    add_index :subjects, :name, unique: true
    add_index :tasks, :name, unique: true
    add_index :categories, :name, unique: true
  end
end
