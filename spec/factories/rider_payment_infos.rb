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
      restaurant_id 0
    end
  end
end
