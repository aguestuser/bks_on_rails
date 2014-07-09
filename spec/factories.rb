FactoryGirl.define do

  factory :contact_info do
    name 'Wonderful Person'
    title 'Doer of Great Things'
    phone '917-345-3200'
    email 'wonderfulperson@example.com'
    street_address '446 Dean St'
    borough :brooklyn #Borough::Brooklyn.new.text
    neighborhood :park_slope #Neighborhood::ParkSlope.new.text
  end

  factory :staffer, class: "Staffer" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:staffer_contact_info, contactable: f)
    end
  end

  factory :staffer_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Staffer'
    title 'Accounts Manager'
    phone '917-345-3200'
    email 'wonderfulstaffer@example.com'
    association :contactable , factory: :staffer
  end

  factory :restaurant, class: "Restaurant" do
    active true
    status :new_account #AccountStatus::NewAccount.new.text # AccountStatuses::NewAccount
    description "is a newly signed up account. They say it gets busy. Let us know how it goes!"
    agency_payment_method :cash #AgencyPaymentMethod::Cash.new.text
    pickup_required true
    # managers { 
    #   2.times.map do
    #    FactoryGirl.build(:manager) 
    #   end
    # }
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:restaurant_contact_info, contactable: f)
      f.managers = 2.times.map { FactoryGirl.build(:manager, restaurant: f) }
      f.work_arrangement = FactoryGirl.build(:work_arrangement, restaurant: f)
    end
  end

  factory :work_arrangement do
    
    restaurant

    zone 'big'
    daytime_volume 'slow'
    evening_volume 'busy'
    extra_work true    
    extra_work_description 'lick balls'
    
    rider_payment_method :cash #AgencyPaymentMethod::Cash.new.text
    pay_rate '$10/hr'
    shift_meal false
    cash_out_tips true
    
    bike true
    lock true
    rack true
    bag true
    heated_bag false   
  end

  factory :restaurant_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Restaurant'
    phone '917-345-3200'
    street_address '446 Dean St'
    borough :brooklyn #Borough::Brooklyn.new.text
    neighborhood :park_slope #Neighborhood::ParkSlope.new.text
    association :contactable, factory: :restaurant
  end

  factory :manager, class: "Manager" do
    restaurant
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:manager_contact_info, contactable: f)
    end
  end

  factory :manager_contact_info, class: 'ContactInfo' do  
    sequence(:name) { |n| "Manager#{n}" }
    title 'Manager'
    phone '917-345-3200'
    sequence(:email) { |n| "manager#{n}@example.com" }
    association :contactable , factory: :manager
  end

  factory :rider, class: "Rider" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:rider_contact_info, contactable: f)
    end
  end

  factory :rider_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Guy'
    phone '917-345-3200'
    email 'wonderfulguy@example.com'
    borough :brooklyn #Borough::Brooklyn.new.text
    neighborhood :park_slope #Neighborhood::ParkSlope.new.text
    association :contactable, factory: :rider
  end

end


# { name: 'Wonderful Guy', title: 'Accounts Manager', phone: '555-555-5555', email: 'wonderfulguy@example.com', street_address: '446 Dean St', borough: Borough::Brooklyn.new.text, neighborhood: Neighborhood::ParkSlope.new.text }
