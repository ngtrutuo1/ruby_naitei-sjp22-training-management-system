class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :taskable, polymorphic: true, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
