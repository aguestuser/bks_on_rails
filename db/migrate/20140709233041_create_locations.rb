class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :locatable, polymorphic: true
      t.string :address
      t.string :borough
      t.string :neighborhood

      t.timestamps
    end
  end
end
