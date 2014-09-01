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
      f.contact = FactoryGirl.build(:contact, :with_contactable, contactable: f)
      f.account = FactoryGirl.build(:account, :with_user, user: f)
    end
  end
  trait :tess do
    after(:build) do |f|
      f.contact = FactoryGirl.build(:contact, :with_contactable, contactable: f, name: "Tess Cohen", title: "Accounts Executive", email: "tess@bkshift.test", phone: "347-460-6484")
      f.account = FactoryGirl.build(:account, :with_user, user: f)
    end
  end
  trait :justin do
    after(:build) do |f|
      f.contact = FactoryGirl.build(:contact, :with_contactable, contactable: f, name: "Justin Lewis", title: "Accounts Manager", email: "justin@bkshift.test", phone: "347-460-6484")
      f.account = FactoryGirl.build(:account, :with_user, user: f)
    end
  end
end
