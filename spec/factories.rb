FactoryGirl.define do
  
  factory :phone_number do
    type 'Cell'
    primary true
    value '555-555-5555'
  end

  factory :email_address do
    primary true
    value "rider@example.com"    
  end

  factory :location do
    address '446 Dean St.'
    lat 40.6819339
    lng -73.9764676
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

end