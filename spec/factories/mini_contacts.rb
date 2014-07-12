# == Schema Information
#
# Table name: mini_contacts
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  phone         :string(255)
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mini_contact do
    name "Wonderful Restaurant"
    phone "831-915-5000"
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
  end
end
