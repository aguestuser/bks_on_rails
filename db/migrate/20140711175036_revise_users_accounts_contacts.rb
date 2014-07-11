class ReviseUsersAccountsContacts < ActiveRecord::Migration
  def change
    rename_table :user_infos, :accounts
    rename_table :contact_infos, :contacts
  end
end
