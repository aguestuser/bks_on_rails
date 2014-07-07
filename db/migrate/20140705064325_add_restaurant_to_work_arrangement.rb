class AddRestaurantToWorkArrangement < ActiveRecord::Migration
  def change
    add_reference :work_arrangements, :restaurant, index: true
  end
end
