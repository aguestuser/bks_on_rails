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
    date "2014-07-23 14:44:22"
    period :am
    trait :with_rider do |rider|
      rider
    end
    trait :without_rider do
      rider_id 1
    end
  end
end
