FactoryGirl.define do
  
  factory :contact_info do
    name 'Wonderful Guy'
    phone '555-555-5555'
    email 'wonderfulguy@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

  factory :staffer do
    title 'Accounts Manager'
    contact_info { FactoryGirl.build(:contact_info) }
  end
end