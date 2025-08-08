class AddUniqueIndexesToCategoriesAndSubjects < ActiveRecord::Migration[7.0]
  def change
    add_index :categories, :name, unique: true unless index_exists?(:categories, :name, unique: true)
    add_index :subjects, :name, unique: true unless index_exists?(:subjects, :name, unique: true)
  end
end
