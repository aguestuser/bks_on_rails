# == Schema Information
#
# Table name: managers
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :manager, class: "Manager" do
    trait :with_restaurant do |restaurants|
      restaurants
    end
    trait :without_restaurant do
      restaurants = []
    end
    after(:build) do |f|
      f.account = FactoryGirl.build(:account, :with_user, user: f)
      f.contact = FactoryGirl.build(:contact, :with_contactable, contactable: f)
    end
  end

end
