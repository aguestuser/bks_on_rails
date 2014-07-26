# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  start      :datetime
#  end        :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conflict do
    sequence(:start) { |n| n.days.from_now.beginning_of_day + 11.hours }
    sequence(:end) { |n| n.days.from_now.beginning_of_day + 16.hours }
    trait :with_rider do |rider|
      rider
    end
    trait :without_rider do
      rider_id 1
    end
  end
end
