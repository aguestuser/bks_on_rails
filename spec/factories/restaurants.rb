FactoryGirl.define do
  factory :restaurant, class: "Restaurant" do
    active true
    status :new_account #AccountStatus::NewAccount.new.text # AccountStatuses::NewAccount
    brief "is a newly signed up account. They say it gets busy. Let us know how it goes!"

    after(:build) do |f|
      f.short_contact_info = FactoryGirl.build(:short_contact_info, :with_restaurant, restaurant: f)
      f.location = FactoryGirl.build(:location, :with_locatable, locatable: f)
      f.managers = 2.times.map { FactoryGirl.build(:manager, :with_restaurant, restaurant: f) }
      f.rider_payment_info = FactoryGirl.build(:rider_payment_info, :with_restaurant, restaurant: f)
      f.work_specification = FactoryGirl.build(:work_specification, :with_restaurant, restaurant: f)
      f.agency_payment_info = FactoryGirl.build(:agency_payment_info, :with_restaurant, restaurant: f)
      f.equipment_set = FactoryGirl.build(:equipment_set, :with_equipable, equipable: f)
    end
  end
end