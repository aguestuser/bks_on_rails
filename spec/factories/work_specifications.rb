# == Schema Information
#
# Table name: work_specifications
#
#  id                     :integer          not null, primary key
#  restaurant_id          :integer
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  extra_work             :string(255)
#  extra_work_description :text
#  created_at             :datetime
#  updated_at             :datetime
#

FactoryGirl.define do
  factory :work_specification do
    zone 'big'
    daytime_volume 'slow'
    evening_volume 'busy'
    extra_work true    
    extra_work_description 'lick balls'
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end    
  end
end
