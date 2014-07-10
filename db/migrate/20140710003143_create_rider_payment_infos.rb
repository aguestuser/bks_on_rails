class CreateRiderPaymentInfos < ActiveRecord::Migration
  def change
    create_table :rider_payment_infos do |t|
      t.references :restaurant, index: true
      t.string :method
      t.string :rate
      t.boolean :shift_meal
      t.boolean :cash_out_tips

      t.timestamps
    end
  end
end
