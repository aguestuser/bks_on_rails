class AssociateContactsWithUsersNotAccounts < ActiveRecord::Migration
  def change
    remove_reference :contacts, :account
    add_reference :contacts, :contactable, polymorphic: true, index: true
    
  end
end
