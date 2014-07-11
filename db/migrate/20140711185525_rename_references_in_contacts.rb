class RenameReferencesInContacts < ActiveRecord::Migration
  def change
    remove_index :contacts, :contact_id
    remove_reference :contacts, :contact, polymorphic: true
    add_reference :contacts, :account, index: true
  end
end
