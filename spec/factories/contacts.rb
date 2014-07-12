# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  phone      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#  email      :string(255)
#  title      :string(255)
#  account_id :integer
#

FactoryGirl.define do
  factory :contact do
    name 'Wonderful Person'
    title 'Head of Wonder'
    sequence(:email) { |n| "wonderful#{n}@example.com" }
    phone '917-345-3200'
    
    trait :with_account do |account|
      account     
    end 
    trait :without_account do
      account_id 0
    end
  end
end
