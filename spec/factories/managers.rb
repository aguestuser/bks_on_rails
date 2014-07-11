FactoryGirl.define do
  factory :manager, class: "Manager" do
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
    after(:build) do |f|
      f.account = FactoryGirl.build(:account, :with_user, user: f)
    end
  end

end