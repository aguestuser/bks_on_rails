class RemoveLocationFromContactInfo < ActiveRecord::Migration
  def change
    remove_column :contact_infos, :borough, :string
    remove_column :contact_infos, :neighborhood, :string
    remove_column :contact_infos, :street_address, :string
  end
end
