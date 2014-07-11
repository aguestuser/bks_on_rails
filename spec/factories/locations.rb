FactoryGirl.define do
  factory :location do
    address '446 Dean St.'
    borough :brooklyn
    neighborhood :park_slope
    trait :with_locatable do |locatable|
      locatable
    end
    trait :without_locatable do
      locatable_id 0
    end
  end
end