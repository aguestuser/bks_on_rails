module RiderMailerMacros
  def load_rider_mailer_scenario
    let(:tess){ FactoryGirl.create(:staffer, :tess) }
    let(:justin){ FactoryGirl.create(:staffer, :justin) }

    let!(:rider){ FactoryGirl.create(:rider) }
    let!(:restaurant){ FactoryGirl.create(:restaurant) }
    
    let(:start_t){ Time.zone.now.beginning_of_day + 12.hours }
    let(:end_t){ Time.zone.now.beginning_of_day + 18.hours }

    let(:extra_shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start_t + 3.days, :end => end_t + 3.days) }
    let(:emergency_shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start_t + 1.day, :end => end_t + 1.day) }

    before do 
      rider.contact.update(name: 'A'*10)
      restaurant.mini_contact.update(name: 'A'*10)
    end    
  end

  def load_batch_delegation_scenario
    let!(:other_rider){ FactoryGirl.create(:rider) }
    let!(:other_restaurant){ FactoryGirl.create(:restaurant) }
    
    let(:extra_shifts) do 
      4.times.map do |n| 
        this_restaurant = (n+2)%2 == 0 ? restaurant : other_restaurant #even shifts belong to restaurant, odd to other_restaurant
        FactoryGirl.create(:shift, :with_restaurant, restaurant: this_restaurant, start: start_t + (n+3).days, :end => end_t + (n+3).days)
      end
    end

    let(:emergency_shifts) do 
      4.times.map do |n| 
        this_restaurant = (n+2)%2 == 0 ? restaurant : other_restaurant
        FactoryGirl.create(:shift, :with_restaurant, restaurant: this_restaurant, start: start_t + ((n+2)/2).days + (n/2*6).hours, :end => end_t + ((n+2)/2).days + (n/2*6).hours)
      end
    end

    let(:mixed_shifts){ [ emergency_shift, extra_shift ] }

    before do
      other_rider.contact.update(name: 'A'*9+'a')
      other_restaurant.mini_contact.update(name: 'A'*9+'a')
    end
  end

  def load_schedule_email_scenario
    let(:restaurants){ 7.times.map{ |n| FactoryGirl.create(:restaurant) } }
    let(:schedule) do
      7.times.map { |n| FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[n], start: start_t.beginning_of_week + 12.hours + (7+n).days, :end => start_t.beginning_of_week + 18.hours + (7+n).days) }
    end
  end

  # def load_delegation_email_scenario
  #   let(:mail){ RiderMailer.delegation_email rider, shift }
  # end

  def delegate shift
    visit edit_shift_assignment_path(shift, shift.assignment)
    select rider.name, from: "assignment_rider_id"
    select 'Delegated', from: "assignment_status"
    click_button 'Save changes'
  end

  def batch_delegate shifts
    visit shifts_path
    #set time filters inclusively
    select Time.zone.now.year - 1, from: 'filter_start_year'
    select Time.zone.now.year + 1, from: 'filter_end_year'
    #filter out all restaurants but test restaurants
    Restaurant.all.each { |r| unselect r.name, from: 'filter_restaurants' }
    select restaurant.name, from: "filter_restaurants"
    select other_restaurant.name, from: "filter_restaurants"
    click_button 'Filter' 
    #sort by restaurant
    click_link 'Restaurant'
    #select and submit test restaurants' shifts for batch assignment
    page.within("#row_1"){ find("#ids_").set true }
    page.within("#row_2"){ find("#ids_").set true }
    page.within("#row_3"){ find("#ids_").set true } 
    page.within("#row_4"){ find("#ids_").set true } 
    click_button 'Batch Assign', match: :first
    #batch assign shifts (first two shifts to rider, second two to other_rider)
    page.within("#shift_#{shifts[0].id}") do
      find("#assignments__rider_id").select rider.name
      find("#assignments__status").select 'Delegated'
    end
    page.within("#shift_#{shifts[1].id}") do
      find("#assignments__rider_id").select rider.name
      find("#assignments__status").select 'Delegated'
    end
    page.within("#shift_#{shifts[2].id}") do
      find("#assignments__rider_id").select other_rider.name
      find("#assignments__status").select 'Delegated'
    end
    page.within("#shift_#{shifts[3].id}") do
      find("#assignments__rider_id").select other_rider.name
      find("#assignments__status").select 'Delegated'
    end
    puts 'saved changes'
  end

  def check_shift_delegation_email_contents staffer, type, shift
    expect(mail.to).to eq [ rider.email ]
    expect(mail.subject).to eq "[#{type.to_s.upcase} SHIFT] #{shift.table_time} @ #{shift.restaurant.name}"
    expect(mail.from).to eq [ "brooklynshift@gmail.com" ]
    expect(mail.body.encoded.to_s).to eq expected_delegation_email_body(staffer, type, shift)
  end

  def check_batch_delegation_email_contents staffer, type, 

  def expected_delegation_email_body staffer, type, shift
    signature = signature_from staffer
    "<!DOCTYPE html>\r\n<html>\r\n<head>\r\n<meta content='text/html; charset=UTF-8' http-equiv='Content-Type'>\r\n<style>\r\n  table { \r\n    border-collapse:collapse;\r\n    margin-left: 2em;\r\n  }\r\n  th {\r\n    background-color: lightgray;\r\n  }\r\n  th, td {\r\n    border: 1px solid black;\r\n    margin: 0px;\r\n    padding: .5em;\r\n  }\r\n  .underline {\r\n    text-decoration: underline;\r\n  }\r\n</style>\r\n</head>\r\n<body>\r\n<p>\r\nDear AAAAAAAAAA:\r\n</p>\r\n<p>\r\n#{offering_for type}\r\n</p>\r\n<table>\r\n<tr>\r\n<th>\r\nTime\r\n</th>\r\n<th>\r\nRestaurant\r\n</th>\r\n</tr>\r\n<tr>\r\n<td>\r\n#{shift.table_time}\r\n</td>\r\n<td>\r\nAAAAAAAAAA\r\n</td>\r\n</tr>\r\n</table>\r\n<p>\r\n#{confirmation_request_for type}\r\n</p>\r\n<p></p>\r\n<p>\r\nBest,\r\n</p>\r\n#{signature}\r\n\r\n<strong class='underline'>\r\nRestaurant Briefs:\r\n</strong>\r\n<p>\r\n<strong>\r\nAAAAAAAAAA:\r\n</strong>\r\nis a newly signed up account. They say it gets busy. Let us know how it goes!\r\n<br>\r\n<strong>\r\nLocation:\r\n</strong>\r\n446 Dean St., Brooklyn [Park Slope]\r\n</p>\r\n\r\n<strong class='underline'>\r\nReminders:\r\n</strong>\r\n<ul>\r\n<li>\r\nDon’t forget to text 347-460-6484 2 hrs before your shift\r\n</li>\r\n<li>\r\nPlease arrive 15 minutes before your scheduled shift\r\n</li>\r\n<li>\r\nPlease note that the DOT requires the use of helmets, front white light, back red light and a bell and/or whistle.\r\n</li>\r\n</ul>\r\n\r\n\r\n</body>\r\n</html>\r\n"
  end

  def offering_for type
    case type
    when :extra
      "We'd like to offer you the following extra shift:"
    when :emergency
      "We'd like to offer you the following emergency shift:"
    when :weekly
      "We'd like to offer you the following weekly schedule:"
    end
  end

  def confirmation_request_for type
    case type
    when :extra
      "Please confirm whether you can work the shift by 2pm tomorrow"
    when :emergency
      "Please confirm whether you can work the shift by 2pm tomorrow"
    when :weekly
      "Please confirm whether you can work the shift by 12pm this Sunday"
    end
  end

  def signature_from staffer
    case staffer 
    when :tess
      "<p>\r\nTess Cohen\r\n<br>\r\nAccounts Executive\r\n<br>\r\nBK Shift, LLC\r\n<br>\r\n347-460-6484\r\n<br>\r\ntess@bkshift.test\r\n</p>"
    when :justin
      "<p>\r\nJustin Lewis\r\n<br>\r\nAccounts Manager\r\n<br>\r\nBK Shift, LLC\r\n<br>\r\n347-460-6484\r\n<br>\r\njustin@bkshift.test\r\n</p>"
    end   
  end
  
end
