class AddAssociationToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :contactable_id, :integer
    add_index :contact_infos, :contactable_id
  end
end
