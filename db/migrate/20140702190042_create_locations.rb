class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :address
      t.decimal :lat, :decimal, {:precision=>10, :scale=>6}
      t.decimal :lng, :decimal, {:precision=>10, :scale=>6}
      t.string :borough
      t.string :neighborhood

      t.timestamps
    end
  end
end
