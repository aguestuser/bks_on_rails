FactoryGirl.define do

  factory :contact_info do
    name 'Wonderful Person'
    title 'Doer of Great Things'
    phone '111-111-1111'
    email 'wonderfulperson@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

  factory :staffer, class: "Staffer" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:staffer_contact_info, contactable: f)
    end
  end

  factory :staffer_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Staffer'
    title 'Accounts Manager'
    phone '222-222-2222'
    email 'wonderfulstaffer@example.com'
    association :contactable , factory: :staffer
  end

  factory :restaurant, class: "Restaurant" do
    active true
    status 'new account'
    description "is a newly signed up account. They say it gets busy. Let us know how it goes!"
    payment_method 'cash'
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
    rider_payment_method 'cash'

    pay_rate '$10/hr'
    shift_meal false
    cash_out_tips true
    rider_on_premises true
    extra_work true
    extra_work_description 'lick balls'

    bike true
    lock true
    rack true
    bag true
    heated_bag false   
  end

  factory :restaurant_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Restaurant'
    phone '333-333-3333'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
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
    phone '222-222-2222'
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
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
    association :contactable, factory: :rider
  end

end


#{ name: 'Wonderful Guy', title: 'Accounts Manager', phone: '555-555-5555', email: 'wonderfulguy@example.com', street_address: '446 Dean St', borough: 'Brooklyn', neighborhood: 'Park Slope' }
