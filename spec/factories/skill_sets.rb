# == Schema Information
#
# Table name: skill_sets
#
#  id            :integer          not null, primary key
#  rider_id      :integer
#  bike_repair   :boolean
#  fix_flats     :boolean
#  early_morning :boolean
#  pizza         :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :skill_set do
    bike_repair true
    fix_flats true
    early_morning false
    pizza false
    trait :without_rider do
      rider_id 0
    end
    trait :with_rider do |rider|
      rider
    end    
  end
end
