class AddUneditedToRestaurants < ActiveRecord::Migration
  def change
    add_column :restaurants, :unedited, :boolean
  end
end
