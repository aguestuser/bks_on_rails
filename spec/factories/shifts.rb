# == Schema Information
#
# Table name: shifts
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  start         :datetime
#  end           :datetime
#  period        :string(255)
#  urgency       :string(255)
#  billing_rate  :string(255)
#  notes         :text
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :shift do
    sequence(:start) { |n| n.days.from_now.beginning_of_day + 12.hours }
    sequence(:end) { |n| n.days.from_now.beginning_of_day + 18.hours }
    period :pm
    billing_rate :normal
    urgency :weekly
    notes 'Nobody wants to work this shift!'
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      # restaurant_id 1
      sequence(:restaurant_id) { |n| n + 1 }
    end
  end
end
