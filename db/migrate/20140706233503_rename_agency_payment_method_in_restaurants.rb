class RenameAgencyPaymentMethodInRestaurants < ActiveRecord::Migration
  change_table :restaurants do |t|
    t.rename :payment_method, :agency_payment_method
  end
end
