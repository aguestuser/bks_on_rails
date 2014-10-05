class CreateEquipmentNeeds < ActiveRecord::Migration
  def change
    create_table :equipment_needs do |t|
      t.boolean :bike_provided
      t.boolean :rack_required
      t.references :restaurant, index: true

      t.timestamps
    end
  end
end
