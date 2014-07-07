class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.references :restaurant, index: true
      
      t.datetime :start
      t.datetime :end
      t.string :period
      t.string :urgency
      t.string :billing_rate
      t.text :notes

      t.timestamps
    end
  end
end
