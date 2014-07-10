class CreateEquipmentSets < ActiveRecord::Migration
  def change
    create_table :equipment_sets do |t|
      t.references :equipable, polymorphic: true, index: true
      t.boolean :bike
      t.boolean :lock
      t.boolean :helmet
      t.boolean :rack
      t.boolean :bag
      t.boolean :heated_bag
      t.boolean :cell_phone
      t.boolean :smart_phone

      t.timestamps
    end
  end
end
