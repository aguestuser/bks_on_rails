# == Schema Information
#
# Table name: restaurants
#
#  id         :integer          not null, primary key
#  active     :boolean
#  status     :string(255)
#  brief      :text
#  created_at :datetime
#  updated_at :datetime
#  unedited   :boolean
#

FactoryGirl.define do
  factory :restaurant, class: "Restaurant" do
    active true
    status :new_account #AccountStatus::NewAccount.new.text # AccountStatuses::NewAccount
    brief "is a newly signed up account. They say it gets busy. Let us know how it goes!"
    unedited false

    after(:build) do |f|
      f.mini_contact = FactoryGirl.build(:mini_contact, :with_restaurant, restaurant: f)
      f.location = FactoryGirl.build(:location, :with_locatable, locatable: f)
      f.managers = 2.times.map { FactoryGirl.build(:manager, :with_restaurant, restaurant: f) }
      f.rider_payment_info = FactoryGirl.build(:rider_payment_info, :with_restaurant, restaurant: f)
      f.work_specification = FactoryGirl.build(:work_specification, :with_restaurant, restaurant: f)
      f.agency_payment_info = FactoryGirl.build(:agency_payment_info, :with_restaurant, restaurant: f)
      f.equipment_need = FactoryGirl.build(:equipment_need, restaurant: f)
    end
  end
end
