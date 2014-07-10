# == Schema Information
#
# Table name: rider_ratings
#
#  id             :integer          not null, primary key
#  rider_id       :integer
#  initial_points :integer
#  likeability    :integer
#  reliability    :integer
#  speed          :integer
#  points         :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rider_rating do
    initial_points 75
    likeability 1
    reliability 1
    speed 1
    points 0
    trait :without_rider do
      rider_id 0
    end
    trait :with_rider do |rider|
      rider
    end  
  end
end
