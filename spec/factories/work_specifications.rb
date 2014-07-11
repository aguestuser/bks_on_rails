FactoryGirl.define do
  factory :work_specification do
    zone 'big'
    daytime_volume 'slow'
    evening_volume 'busy'
    extra_work true    
    extra_work_description 'lick balls'
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end    
  end
end