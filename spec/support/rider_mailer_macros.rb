module RiderMailerMacros
  def load_rider_mailer_scenario
    let(:rider){ FactoryGirl.create(:rider) }
    let(:restaurant){ FactoryGirl.create(:restaurant) }
    let(:start_t){ Time.zone.local(2014,1,1,12) }
    let(:end_t){ Time.zone.local(2014,1,1,18) }

    let(:shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start_t, :end => end_t) }
    let(:tess){ FactoryGirl.create(:staffer, :tess) }
    let(:other_staffer){ FactoryGirl.create(:staffer) }
    
    before do 
      rider.contact.update(name: 'A'*10)
      restaurant.mini_contact.update(name: 'z'*10)
    end    
  end

  def load_delegation_email_scenario
    let(:mail){ RiderMailer.delegation_email rider, shift }
  end

  def expected_delegation_email_body
    "<!DOCTYPE html>\r\n<html>\r\n<head>\r\n<meta content='text/html; charset=UTF-8' http-equiv='Content-Type'>\r\n<style>\r\n  table { \r\n    border-collapse:collapse;\r\n    margin-left: 2em;\r\n  }\r\n  th {\r\n    background-color: lightgray;\r\n  }\r\n  th, td {\r\n    border: 1px solid black;\r\n    margin: 0px;\r\n    padding: .5em;\r\n  }\r\n  .underline {\r\n    text-decoration: underline;\r\n  }\r\n</style>\r\n</head>\r\n<body>\r\n<p>\r\nDear AAAAAAAAAA:\r\n</p>\r\n<p>\r\nWe'd like to offer you the following extra shift:\r\n</p>\r\n<table>\r\n<tr>\r\n<th>\r\nTime\r\n</th>\r\n<th>\r\nRestaurant\r\n</th>\r\n</tr>\r\n<tr>\r\n<td>\r\n1/1 | WED | 12:00PM - 6:00PM\r\n</td>\r\n<td>\r\nzzzzzzzzzz\r\n</td>\r\n</tr>\r\n</table>\r\n<p></p>\r\n<p>\r\nBest,\r\n</p>\r\n<p>\r\nTess Cohen\r\n<br>\r\nAccounts Executive\r\n<br>\r\nBK Shift, LLC\r\n<br>\r\n347-460-6484\r\n<br>\r\ntess@bkshift.com\r\n<br>\r\n</p>\r\n\r\n<strong class='underline'>\r\nRestaurant Briefs:\r\n</strong>\r\n<p>\r\n<strong>\r\nzzzzzzzzzz:\r\n</strong>\r\nis a newly signed up account. They say it gets busy. Let us know how it goes!\r\n<br>\r\n<strong>\r\nLocation:\r\n</strong>\r\n446 Dean St., Brooklyn [Park Slope]\r\n</p>\r\n\r\n<strong class='underline'>\r\nReminders:\r\n</strong>\r\n<ul>\r\n<li>\r\nDon’t forget to text 347-460-6484 2 hrs before your shift\r\n</li>\r\n<li>\r\nPlease arrive 15 minutes before your scheduled shift\r\n</li>\r\n<li>\r\nPlease note that the DOT requires the use of helmets, front white light, back red light and a bell and/or whistle.\r\n</li>\r\n</ul>\r\n\r\n\r\n</body>\r\n</html>\r\n"  
  end

  def delegate_shift
    visit edit_shift_assignment_path(shift, shift.assignment)
    select rider.name, from: "assignment_rider_id"
    select 'Delegated', from: "assignment_status"
    click_button 'Save changes'
  end

  def check_delegation_email_contents
    expect(mail.to).to eq [ rider.email ]
    expect(mail.subject).to eq "[EXTRA SHIFT] #{shift.table_time} @ #{shift.restaurant.name}"
    expect(mail.from).to eq [ "brooklynshift@gmail.com" ]
    expect(mail.body.encoded).to eq expected_delegation_email_body
  end
end