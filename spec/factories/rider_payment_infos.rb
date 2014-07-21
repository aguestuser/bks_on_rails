# == Schema Information
#
# Table name: rider_payment_infos
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  method        :string(255)
#  rate          :string(255)
#  shift_meal    :boolean
#  cash_out_tips :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :rider_payment_info do
    method :cash #AgencyPaymentMethod::Cash.new.text
    rate '$10/hr'
    shift_meal false
    cash_out_tips true
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 1
    end
  end
end
