class CreateWorkSpecifications < ActiveRecord::Migration
  def change
    create_table :work_specifications do |t|
      t.references :restaurant, index: true
      t.string :zone
      t.string :daytime_volume
      t.string :evening_volume
      t.string :extra_work
      t.text :extra_work_description

      t.timestamps
    end
  end
end
