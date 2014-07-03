class AddNameAndUniqueEmailIndexToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :name, :string
    add_index :contact_infos, :email, unique: true
  end
end
