class AddCarToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment_sets, :car, :boolean
  end
end
