# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rider do
    active true
    after(:build) do |f|
      f.account = FactoryGirl.build(:account, :with_user, user: f)
      f.contact = FactoryGirl.build(:contact, :with_contactable, contactable: f)
      f.location = FactoryGirl.build(:location, :with_locatable, locatable: f)
      f.equipment_set = FactoryGirl.build(:equipment_set, :with_equipable, equipable: f)
      f.qualification_set = FactoryGirl.build(:qualification_set, :with_rider, rider: f)
      f.skill_set = FactoryGirl.build(:skill_set, :with_rider, rider: f)
      f.rider_rating = FactoryGirl.build(:rider_rating, :with_rider, rider: f)
    end
  end
end
