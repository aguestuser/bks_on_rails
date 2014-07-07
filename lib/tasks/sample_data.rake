namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_staffers
    make_restaurants
  end
end

def make_staffers
  
  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Austin Guest',
      title: 'IT Director',
      email: 'austin@bkshift.com',
      phone: '831-917-6400'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Tess Cohen',
      title: 'Accounts Executive',
      email: 'tess@bkshift.com',
      phone: '347-460-6484'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Justin Lewis',
      title: 'Accounts Manager',
      email: 'justin@bkshift.com',
      phone: '347-460-6484'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Yagil Kadosh',
      title: 'Partner Relations Director',
      email: 'yagil@bkshift.com',
      phone: '201-341-9442'
    )
  )

end

def make_restaurants
  20.times do |n|
    Faker::Config.locale = 'en-us'
    rest_name = Faker::Company.name
    rest_phone = '222-222-2222'
    address = Faker::Address.street_address
    name = Faker::Name.name
    title = Faker::Name.title
    phone = '222-222-2222'
    email = Faker::Internet.email
    borough = [ :brooklyn, :manhattan, :queens, :bronx ].sample
    neighborhood = [ :park_slope, :fort_greene, :gowanus, 
      :midtown_west, :midtown_east, :west_village, :east_village, 
      :chelsea, :prospect_heights, :boerum_hill, :east_harlem ].sample
    status = [ :stable, :at_risk, :at_high_risk, :emergency_only, :variable_needs, :inactive ].sample

    rest_contact = ContactInfo.new(
      name: rest_name,
      phone: rest_phone,
      street_address: address,
      borough: borough,
      neighborhood: neighborhood,
      # contactable_type: 'Restaurant' 
    )
    
    man_contact = ContactInfo.new(
      name: name,
      title: title,
      phone: phone,
      email: email,
      contactable_type: 'Manager' 
    )

    manager = Manager.new(
      contact_info: man_contact
    )

    work_arr = WorkArrangement.new(
      zone: 'Really fucking big',
      daytime_volume: 'Slow as fuck',
      evening_volume: 'Faster than all fuck',
      rider_payment_method: :cash,
      pay_rate: '$10/hr',
      shift_meal: false,
      cash_out_tips: true,
      extra_work: true,
      extra_work_description: 'Clean toilet seats with bare hands',
      bike: true,
      lock: true,
      rack: true,
      bag: true,
      heated_bag: false 
    )

    Restaurant.create!(
      active: true,
      status: status,
      description: "is a newly signed up account. They say it gets busy. Let us know how it goes!",
      agency_payment_method: :cash,
      pickup_required: true,
      contact_info: rest_contact,
      managers: [manager],
      work_arrangement: work_arr
    )
  end
end