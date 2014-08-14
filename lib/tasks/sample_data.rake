Faker::Config.locale = 'en-us'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_staffers
    make_restaurants
    make_shifts
    make_riders
    make_assignments
    make_conflicts
  end
end

def make_staffers
  
  Staffer.create!(
    account: Account.new(
      password: 'foobar',
      password_confirmation: 'foobar'
    ),
    contact: Contact.new(
      name: 'Austin Guest',
      title: 'IT Director',
      email: 'austin@bkshift.com',
      phone: '831-917-6400'
    )
  )

  Staffer.create!(
    account: Account.new(
      password: 'foobar',
      password_confirmation: 'foobar'
    ),
    contact: Contact.new(
      name: 'Tess Cohen',
      title: 'Accounts Executive',
      email: 'tess@bkshift.com',
      phone: '347-460-6484'
    )    
  )

  Staffer.create!(
    account: Account.new(
      password: 'foobar',
      password_confirmation: 'foobar'
    ),
    contact: Contact.new(
      name: 'Justin Lewis',
      title: 'Accounts Manager',
      email: 'justin@bkshift.com',
      phone: '347-460-6484'
    )
  )

  Staffer.create!(
    account: Account.new(
      password: 'foobar',
      password_confirmation: 'foobar'      
    ),
    contact: Contact.new(
      name: 'Yagil Kadosh',
      title: 'Partner Relations Director',
      email: 'yagil@bkshift.com',
      phone: '201-341-9442'
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

    mini_contact = MiniContact.new(
      name: rest_name,
      phone: rest_phone
    )
    
    manager = Manager.new(
      account: Account.new(
        password: 'foobar',
        password_confirmation: 'foobar'
      ),
      contact: Contact.new(
        name: name,
        title: title,
        phone: phone,
        email: email,
      )      
    )

    work_spec = WorkSpecification.new(
      zone: '5 mile radius',
      daytime_volume: "#{[5,10,15].sample} deliveries",
      evening_volume: "#{[10,15,20,25].sample} deliveries",
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
      helmet: [true, false].sample,
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
      unedited: false,
      active: true,
      status: status,
      brief: "is a newly signed up account. They say it gets busy. Let us know how it goes!",
      mini_contact: mini_contact,
      location: location,
      managers: [manager],
      work_specification: work_spec,
      rider_payment_info: rider_pay,
      equipment_set: equipment_set,
      agency_payment_info: agency_pay
    )
  end

  def make_shifts
    Restaurant.all.each do |restaurant|
      21.times do |n|
        start_1 = times(n)[0][:start]
        end_1 = times(n)[0][:end]
        start_2 = times(n)[1][:start]
        end_2 = times(n)[1][:end]

        Shift.create!(
          restaurant_id: restaurant.id,
          start: start_1,
          :end => end_1,
          billing_rate: :normal,
          urgency: :weekly,
          assignment: Assignment.new
        )
        Shift.create!(
          restaurant_id: restaurant.id,
          start: start_2,
          :end => end_2,
          billing_rate: :normal,
          urgency: :weekly,
          assignment: Assignment.new
        )
      end
    end
  end
end

def make_riders
  30.times do |n|
    name = make_name
    phone = make_phone
    email = make_email
    address = make_address
    borough = pick_borough
    neighborhood = pick_neighorhood

    Rider.create!(
      active: true,
      account: Account.new(
        password: 'foobar',
        password_confirmation: 'foobar'
      ),
      contact: Contact.new(
        name: name,
        title: 'Rider',
        email: email,
        phone: phone
      ),      
      location: Location.new(
        address: address,
        borough: borough,
        neighborhood: neighborhood
      ),
      rider_rating: RiderRating.new(
        reliability: [1,2,3].sample,
        likeability: [1,2,3].sample,
        speed: [1,2,3].sample,
        initial_points: [75,80,90,100].sample
      ),
      qualification_set: QualificationSet.new(
        hiring_assessment: ["Lousy guy. Emergency Only.", "Heady rider. Get 'em to work!", "Middle of the road. Let's see."].sample,
        experience: ["Been doing it for 5 years.", "No experience, loves to bike.", "Just got fired from Artichoke."].sample,
        geography: ["LES and Williamsburg", "Manhattan numbered streets", "Brooklyn only"].sample
      ),
      skill_set: SkillSet.new(
        bike_repair: [true, false].sample,
        fix_flats: [true, false].sample,
        early_morning: [true, false].sample,
        pizza: [true, false].sample
      ),
      equipment_set: EquipmentSet.new(
        bike: [true, false].sample,
        lock: [true, false].sample,
        helmet: [true, false].sample,
        rack: [true, false].sample,
        bag: [true, false].sample,
        heated_bag: [true, false].sample,
        cell_phone: [true, false].sample,
        smart_phone: [true, false].sample,
        car: [true, false].sample
      )     
    )
  end
end

def make_assignments
  Restaurant.all.each do |restaurant|
    restaurant.shifts.last(14).each do |shift|
      rider_id = Rider.all.sample.id
      status = pick_assignment_status
      shift.assignment.update(
        rider_id: rider_id, 
        status: status
      )
    end
  end
end

def make_conflicts
  Rider.all.each_with_index do |rider|
    7.times do |n|
      start = times(n)[0][:start] + 14.days
      end_ = times(n)[0][:end] + 14.days
      Conflict.create!(
        rider_id: rider.id,
        start: start,
        :end => end_
      )
    end
  end
end


# helpers

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
  [ 
    :park_slope, :fort_greene, :gowanus, 
    :midtown_west, :midtown_east, :west_village, :east_village, 
    :chelsea, :prospect_heights, :boerum_hill, :east_harlem 
  ].sample
end

def pick_assignment_status
  [ 
    :proposed, :delegated, :confirmed, :cancelled_by_rider, :cancelled_by_restaurant 
  ].sample
end

def times(n)
  start = Time.zone.now.beginning_of_week.beginning_of_day + n.days + 12.hours
  [
    {
      start: start,
      :end => start + 6.hours
    },
    {
      start: start + 6.hours,
      :end => start + 11.hours
    }
  ]
end


def pick_period
  [
    :am, :pm, :double
  ].sample
end
