# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

FactoryGirl.define do
  factory :account do
    after(:build) do |f|
      f.contact = FactoryGirl.build(:contact, :with_account, account: f)
    end
    trait :with_user do |user|
      user
    end
    trait :without_user do
      user_id 0
    end    
  end
end
