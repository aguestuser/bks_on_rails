class CreateAgencyPaymentInfos < ActiveRecord::Migration
  def change
    create_table :agency_payment_infos do |t|
      t.string :method
      t.boolean :pickup_required
      t.references :restaurant, index: true

      t.timestamps
    end
  end
end
