# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  user_type       :string(255)
#  password_digest :string(255)
#  remember_token  :string(255)
#

FactoryGirl.define do
  factory :account do
    password 'changeme123'
    password_confirmation 'changeme123'
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
