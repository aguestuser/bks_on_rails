class CreateRiderRatings < ActiveRecord::Migration
  def change
    create_table :rider_ratings do |t|
      t.references :rider, index: true
      t.integer :initial_points
      t.integer :likeability
      t.integer :reliability
      t.integer :speed
      t.integer :points

      t.timestamps
    end
  end
end
