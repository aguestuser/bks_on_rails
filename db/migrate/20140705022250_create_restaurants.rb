class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.boolean :active
      t.string :status
      t.text :description
      t.string :payment_method
      t.boolean :pickup_required

      t.timestamps
    end
  end
end
