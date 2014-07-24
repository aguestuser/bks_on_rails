# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  date       :datetime
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conflict do
    sequence(:date) { |n| n.days.from_now.beginning_of_day }
    sequence(:period) { |n| [ :am, :pm, :double ][n % 3] }
    trait :with_rider do |rider|
      rider
    end
    trait :without_rider do
      rider_id 1
    end
  end
end
