# == Schema Information
#
# Table name: assignments
#
#  id                      :integer          not null, primary key
#  shift_id                :integer
#  rider_id                :integer
#  status                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  override_conflict       :boolean
#  override_double_booking :boolean
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment do
    rider
    status :proposed

    association :shift, :without_restaurant
  end
end
