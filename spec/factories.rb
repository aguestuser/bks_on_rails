FactoryGirl.define do

  factory :staffer, class: "Staffer" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:staffer_contact_info, contactable: f)
    end
  end

  factory :restaurant, class: "Restaurant" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:restaurant_contact_info, contactable: f)
    end
  end

  factory :rider, class: "Rider" do
    after(:build) do |f|
      f.contact_info = FactoryGirl.build(:rider_contact_info, contactable: f)
    end
  end

  factory :contact_info do
    name 'Wonderful Person'
    title 'Doer of Great Things'
    phone '111-111-1111'
    email 'wonderfulperson@example.com'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
  end

  factory :staffer_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Staffer'
    title 'Accounts Manager'
    phone '222-222-2222'
    email 'wonderfulstaffer@example.com'
    association :contactable , factory: :staffer
  end

  factory :restaurant_contact_info, class: 'ContactInfo' do  
    name 'Wonderful Restaurant'
    phone '333-333-3333'
    street_address '446 Dean St'
    borough 'Brooklyn'
    neighborhood 'Park Slope'
    association :contactable, factory: :restaurant
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
