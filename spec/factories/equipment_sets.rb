FactoryGirl.define do
  factory :equipment_set do
    bike true
    lock true
    helmet true
    rack true
    bag true
    heated_bag true
    cell_phone true
    smart_phone true
    car false
    trait :with_equipable do |equipable|
      equipable
    end
    trait :without_equipable do
      equipable_id 0
    end
  end
end