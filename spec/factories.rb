FactoryGirl.define do
  
  factory :contact_info do
    name 'Wonderful Guy'
    title 'Accounts Manager'
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

  factory :staffer do
    contact_info { FactoryGirl.build(:contact_info) }
  end
end


{ name: 'Wonderful Guy', title: 'Accounts Manager', phone: '555-555-5555', email: 'wonderfulguy@example.com', street_address: '446 Dean St', borough: 'Brooklyn', neighborhood: 'Park Slope' }
