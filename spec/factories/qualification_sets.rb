# == Schema Information
#
# Table name: qualification_sets
#
#  id                :integer          not null, primary key
#  hiring_assessment :text
#  experience        :text
#  geography         :text
#  created_at        :datetime
#  updated_at        :datetime
#  rider_id          :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :qualification_set do
    hiring_assessment "Can barely ride a bike"
    experience "Has riden all over the place"
    geography "Harlem, Park Slope"
    trait :without_rider do
      rider_id 0
    end
    trait :with_rider do |rider|
      rider
    end
  end
end
