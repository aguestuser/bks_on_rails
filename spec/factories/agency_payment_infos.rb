FactoryGirl.define do
  factory :agency_payment_info do
    method :cash #AgencyPaymentMethod::Cash.new.text
    pickup_required true 
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
  end
end