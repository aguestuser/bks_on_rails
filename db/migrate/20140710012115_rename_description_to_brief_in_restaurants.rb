class RenameDescriptionToBriefInRestaurants < ActiveRecord::Migration
  def change
    rename_column :restaurants, :description, :brief
  end
end
