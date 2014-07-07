class AddRiderPaymentMethodToWorkArrangements < ActiveRecord::Migration
  def change
    add_column :work_arrangements, :rider_payment_method, :string
  end
end
