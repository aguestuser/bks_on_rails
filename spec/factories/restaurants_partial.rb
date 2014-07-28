FactoryGirl.define do
  factory :restaurant_partial, class: "Restaurant" do
    active true
    status :new_account #AccountStatus::NewAccount.new.text # AccountStatuses::NewAccount
    brief "is a newly signed up account. They say it gets busy. Let us know how it goes!"
    unedited true

    after(:build) do |f|
      f.mini_contact = FactoryGirl.build(:mini_contact, :with_restaurant, restaurant: f)
      f.location = FactoryGirl.build(:location, :with_locatable, locatable: f)
      f.managers = [ FactoryGirl.build(:manager, :with_restaurant, restaurant: f) ]
      f.rider_payment_info = FactoryGirl.build(:rider_payment_info, :with_restaurant, restaurant: f)
    end
  end
end
