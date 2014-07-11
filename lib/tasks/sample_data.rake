Faker::Config.locale = 'en-us'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_staffers
    make_restaurants
    make_shifts
  end
end

def make_staffers
  
  Staffer.create!(
    user_info: UserInfo.new(
      contact_info: ContactInfo.new(
        name: 'Austin Guest',
        title: 'IT Director',
        email: 'austin@bkshift.com',
        phone: '831-917-6400'
      )
    )
  )

  Staffer.create!(
    user_info: UserInfo.new(
      contact_info: ContactInfo.new(
        name: 'Tess Cohen',
        title: 'Accounts Executive',
        email: 'tess@bkshift.com',
        phone: '347-460-6484'
      )
    )
  )

  Staffer.create!(
    user_info: UserInfo.new(
      contact_info: ContactInfo.new(
        name: 'Justin Lewis',
        title: 'Accounts Manager',
        email: 'justin@bkshift.com',
        phone: '347-460-6484'
      )
    )
  )

  Staffer.create!(
    user_info: UserInfo.new(
      contact_info: ContactInfo.new(
        name: 'Yagil Kadosh',
        title: 'Partner Relations Director',
        email: 'yagil@bkshift.com',
        phone: '201-341-9442'
      )
    )
  )

end

def make_restaurants
  10.times do

    rest_name = Faker::Company.name
    rest_phone = make_phone
    address = make_address
    name = make_name
    title = Faker::Name.title
    phone = make_phone
    email = make_email
    borough = pick_borough
    neighborhood = pick_neighorhood
    status = [ :stable, :at_risk, :at_high_risk, :emergency_only, :variable_needs, :inactive ].sample

    rest_contact = ShortContactInfo.new(
      name: rest_name,
      phone: rest_phone
    )
    
    manager = Manager.new(
      user_info: UserInfo.new(
        contact_info: ContactInfo.new(
          name: name,
          title: title,
          phone: phone,
          email: email,
        )
      )
    )

    work_spec = WorkSpecification.new(
      zone: '5 mile radius',
      daytime_volume: '#{[5,10,15].sample} deliveries',
      evening_volume: '#{[10,15,20,25].sample} deliveries',
      extra_work: true,
      extra_work_description: 'Clean toilet seats with bare hands',
    )

    rider_pay = RiderPaymentInfo.new(
      method: [:cash, :check].sample,
      rate: '$10/hr',
      shift_meal: [:true, :false].sample,
      cash_out_tips: [:true, :false].sample
    )

    agency_pay = AgencyPaymentInfo.new(
      method: [:cash, :square_app, :venmo, :check].sample,
      pickup_required: false
    )

    equipment_set = EquipmentSet.new(
      bike: [true, false].sample,
      lock: [true, false].sample,
      rack: [true, false].sample,
      bag: [true, false].sample,
      heated_bag: [true, false].sample,
      cell_phone: [true, false].sample,
      smart_phone: [true, false].sample,
      car: [true, false].sample
    )

    location = Location.new(
      address: address,
      borough: borough,
      neighborhood: neighborhood
    )

    Restaurant.create!(
      active: true,
      status: status,
      brief: "is a newly signed up account. They say it gets busy. Let us know how it goes!",
      short_contact_info: rest_contact,
      managers: [manager],
      work_specification: work_spec,
      rider_payment_info: rider_pay,
      agency_payment_info: agency_pay
    )
  end

  def make_shifts
    Restaurant.all.each do |restaurant|
      21.times do |n|
        start_1 = n.days.from_now.beginning_of_day + 12.hours
        end_1 = start_1 + 6.hours
        start_2 = end_1
        end_2 = start_2 + 6.hours

        Shift.create!(
          restaurant_id: restaurant.id,
          start: start_1,
          :end => end_1,
          billing_rate: :normal,
          urgency: :weekly )
        Shift.create!(
          restaurant_id: restaurant.id,
          start: start_2,
          :end => end_2,
          billing_rate: :normal,
          urgency: :weekly )
      end
    end
  end
end

def make_rider
  30.times do |n|
    name = make_name
    phone = make_phone
    email = make_email
    address = make_address
    borough = pick_borough
    neighborhood = pick_neighorhood

    Rider.create!(
      user_info: UserInfo.new(
        contact_info: ContactInfo.new(
          name: name,
          title: 'Rider',
          email: email,
          phone: phone
        )
      ),
      location: Location.new(
        address: address,
        borough: borough,
        neighborhood: neighborhood
      )
    )
  end
end


def make_name
  Faker::Name.name
end

def make_phone
  "#{['212', '718', '917'].sample}-#{['345', '547', '390'].sample}-#{['2323', '1247', '3925'].sample}"
end

def make_email
  Faker::Internet.email
end

def make_address
  Faker::Address.street_address
end

def pick_borough
  [ :brooklyn, :manhattan, :queens, :bronx ].sample
end

def pick_neighorhood
  [ :park_slope, :fort_greene, :gowanus, 
      :midtown_west, :midtown_east, :west_village, :east_village, 
      :chelsea, :prospect_heights, :boerum_hill, :east_harlem ].sample
end