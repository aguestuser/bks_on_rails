class AddContactableTypeToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :contactable_type, :string
  end
end
