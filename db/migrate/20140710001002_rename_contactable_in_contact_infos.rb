class RenameContactableInContactInfos < ActiveRecord::Migration
  def change
    rename_column :contact_infos, :contactable_id, :contact_id
    rename_column :contact_infos, :contactable_type, :contact_type
  end
end
