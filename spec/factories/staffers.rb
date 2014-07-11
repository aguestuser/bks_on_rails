# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :staffer, class: "Staffer" do
    after(:build) do |f|
      f.user_info = FactoryGirl.build(:user_info, :with_user, user: f)
    end
  end
end
