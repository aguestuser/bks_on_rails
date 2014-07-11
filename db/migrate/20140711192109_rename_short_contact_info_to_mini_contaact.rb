class RenameShortContactInfoToMiniContaact < ActiveRecord::Migration
  def change
    rename_table :short_contact_infos, :mini_contacts 
  end
end
