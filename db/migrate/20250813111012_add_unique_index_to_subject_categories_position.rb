class AddUniqueIndexToSubjectCategoriesPosition < ActiveRecord::Migration[7.0]
  def change
    add_index :subject_categories, [:category_id, :position], unique: true, name: 'index_subject_categories_on_category_and_position'
  end
end
