# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  address        :string(255)
#  borough        :string(255)
#  neighborhood   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :location do
    address '446 Dean St.'
    borough :brooklyn
    neighborhood :park_slope
    trait :with_locatable do |locatable|
      locatable
    end
    trait :without_locatable do
      locatable_id 0
    end
  end
end
