class RemovePaymentColumnsFromRestaurants < ActiveRecord::Migration
  def change
    remove_column :restaurants, :agency_payment_method, :string
    remove_column :restaurants, :pickup_required, :boolean
  end
end
