FactoryGirl.define do

  factory :contact_info do
    name 'Wonderful Entity'
    phone '917-345-3200'
    
    trait :with_contact do |contact|
      contact     
    end 
    trait :without_contact do
      contact_id 0
    end
  end

  factory :user_info do
    sequence(:email) { |n| "wonderful#{n}@example.com" }
    title 'Head of Wonder'
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:contact_info, :with_contact, contact: f)
    end

    trait :with_user do |user|
      user
    end
    trait :without_user do
      user_id 0
    end    
  end

  factory :staffer, class: "Staffer" do
    after(:build) do |f|
      f.user_info = FactoryGirl.build(:user_info, :with_user, user: f)
    end
  end

  factory :manager, class: "Manager" do
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end

    after(:build) do |f|
      f.user_info = FactoryGirl.build(:user_info, :with_user, user: f)
    end
  end


  factory :rider, class: "Rider" do
    after(:build) do |f|
      f.user_info = FactoryGirl.build(:user_info, :with_user, user: f)
    end
  end

  factory :restaurant, class: "Restaurant" do
    active true
    status :new_account #AccountStatus::NewAccount.new.text # AccountStatuses::NewAccount
    brief "is a newly signed up account. They say it gets busy. Let us know how it goes!"

    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:contact_info, :with_contact, contact: f)
      f.location = FactoryGirl.build(:location, :with_locatable, locatable: f)
      f.managers = 2.times.map { FactoryGirl.build(:manager, :with_restaurant, restaurant: f) }
      f.rider_payment_info = FactoryGirl.build(:rider_payment_info, :with_restaurant, restaurant: f)
      f.work_specification = FactoryGirl.build(:work_specification, :with_restaurant, restaurant: f)
      f.agency_payment_info = FactoryGirl.build(:agency_payment_info, :with_restaurant, restaurant: f)
      f.equipment_set = FactoryGirl.build(:equipment_set, :with_equipable, equipable: f)
    end
  end

  factory :rider_payment_info do
    method :cash #AgencyPaymentMethod::Cash.new.text
    rate '$10/hr'
    shift_meal false
    cash_out_tips true
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
  end

  factory :work_specification do
    zone 'big'
    daytime_volume 'slow'
    evening_volume 'busy'
    extra_work true    
    extra_work_description 'lick balls'
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end    
  end

  factory :agency_payment_info do
    method :cash #AgencyPaymentMethod::Cash.new.text
    pickup_required true 
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
  end

  factory :equipment_set do
    bike true
    lock true
    helmet true
    rack true
    bag true
    heated_bag true
    cell_phone true
    smart_phone true
    trait :with_equipable do |equipable|
      equipable
    end
    trait :without_equipable do
      equipable_id 0
    end
  end

  factory :location do
    address '446 Dean St.'
    borough :brooklyn
    neighborhood :park_slope
    trait :with_locatable do |locatable|
      locatable
    end
    trait :without_locatable do
      locatable_id 0
    end
  end

  factory :shift do
    start 0.days.ago.beginning_of_day + 12.hours
    self.end 0.days.ago.beginning_of_day + 18.hours
    period :pm
    billing_rate :normal
    urgency :weekly
    notes 'Nobody wants to work this shift!'
    trait :with_restaurant do |restaurant|
      restaurant
    end
    trait :without_restaurant do
      restaurant_id 0
    end
  end
end



# { name: 'Wonderful Guy', title: 'Accounts Manager', phone: '555-555-5555', email: 'wonderfulguy@example.com', street_address: '446 Dean St', borough: Borough::Brooklyn.new.text, neighborhood: Neighborhood::ParkSlope.new.text }
