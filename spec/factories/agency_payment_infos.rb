# == Schema Information
#
# Table name: agency_payment_infos
#
#  id              :integer          not null, primary key
#  method          :string(255)
#  pickup_required :boolean
#  restaurant_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :agency_payment_info do
    method :cash #AgencyPaymentMethod::Cash.new.text
    pickup_required true 
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 1
    end
  end
end
