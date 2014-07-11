# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :staffer do
    after(:build) do |f|
      f.account = FactoryGirl.build(:account, :with_user, user: f)
    end
  end
end
