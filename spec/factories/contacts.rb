# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  phone            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  name             :string(255)
#  email            :string(255)
#  title            :string(255)
#  contactable_id   :integer
#  contactable_type :string(255)
#

FactoryGirl.define do
  factory :contact do
    sequence (:name) { |n| "Wonderful Person #{n}" }
    title 'Head of Wonder'
    sequence(:email) { |n| "wonderful#{n}@example.com" }
    phone '917-345-3200'
    
    trait :with_contactable do |contactable|
      contactable     
    end 
    trait :without_contactable do
      contactable_id 1
    end
  end
end
