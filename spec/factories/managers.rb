FactoryGirl.define do
  factory :manager, class: "Manager" do
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
    after(:build) do |f|
      f.user_info = FactoryGirl.build(:user_info, :with_user, user: f)
    end
  end

end