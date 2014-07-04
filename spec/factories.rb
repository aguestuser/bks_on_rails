FactoryGirl.define do
  
  factory :staffer do
    contact_info { FactoryGirl.build(:staffer_contact_info) }
    # contact_info.email 'staffer@example.com'
  end

  factory :restaurant do
    contact_info { FactoryGirl.build(:restaurant_contact_info) }
  end

  factory :rider do
    contact_info { FactoryGirl.build(:rider_contact_info) }
  end

  factory :contact_info do
    name 'Wonderful Guy'
    title 'Accounts Manager'
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

  factory :staffer_contact_info do
    name 'Wonderful Guy'
    title 'Accounts Manager'
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    association :contactable, factory: :staffer
  end

  factory :rider_contact_info do
    name 'Wonderful Guy'
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
    association :contactable, factory: :staffer
  end

  factory :restaurant_contact_info do
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
    association :contactable, factory: :restaurant    
  end

end


#{ name: 'Wonderful Guy', title: 'Accounts Manager', phone: '555-555-5555', email: 'wonderfulguy@example.com', street_address: '446 Dean St', borough: 'Brooklyn', neighborhood: 'Park Slope' }
