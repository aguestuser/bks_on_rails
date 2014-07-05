class CreateWorkArrangements < ActiveRecord::Migration
  def change
    create_table :work_arrangements do |t|
      t.string :zone
      t.string :day_time_volume
      t.string :evening_volume
      t.string :pay_rate
      t.boolean :shift_meal
      t.boolean :cash_out_tips
      t.boolean :rider_on_premises
      t.boolean :extra_work
      t.string :extra_work_description
      t.boolean :bike
      t.boolean :lock
      t.boolean :rack
      t.boolean :bag
      t.boolean :heated_bag

      t.timestamps
    end
  end
end
