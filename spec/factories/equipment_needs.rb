# == Schema Information
#
# Table name: equipment_needs
#
#  id            :integer          not null, primary key
#  bike_provided :boolean
#  rack_required :boolean
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :equipment_need do
    bike_provided false
    rack_required false
    restaurant nil
  end
end
