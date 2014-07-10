class AddIndexToLocations < ActiveRecord::Migration
  def change
    add_index :locations, :locatable_id
  end
end
