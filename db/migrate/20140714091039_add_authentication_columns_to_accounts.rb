class AddAuthenticationColumnsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :password_digest, :string
    add_column :accounts, :remember_token, :string
    add_index :accounts, :remember_token
  end
end
