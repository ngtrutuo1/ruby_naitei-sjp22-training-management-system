class ConvertToDevise < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      remove_column :users, :password_digest, :string if column_exists?(:users, :password_digest)
      remove_column :users, :remember_digest, :string if column_exists?(:users, :remember_digest)
      remove_column :users, :activation_digest, :string if column_exists?(:users, :activation_digest)
      remove_column :users, :reset_digest, :string if column_exists?(:users, :reset_digest)
      remove_column :users, :activated, :boolean if column_exists?(:users, :activated)
      remove_column :users, :activated_at, :datetime if column_exists?(:users, :activated_at)
      remove_column :users, :reset_sent_at, :datetime if column_exists?(:users, :reset_sent_at)

      t.string :encrypted_password, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
  end
end
