class RiderMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"

  def delegation_email rider, shifts, restaurants, account, type
    require 'delegation_email_helper'

    @rider = rider
    @shifts = shifts
    @restaurants = restaurants
    @staffer = account.user #, staffer_from account

    helper = DelegationEmailHelper.new shifts, type

    @salutation = "Dear #{rider.first_name}:"
    @offering = helper.offering
    @confirmation_request = helper.confirmation_request
    
    mail(to: rider.email, subject: helper.subject)
  end

  def conflicts_request rider, conflicts, account
    # puts ">>>> rider: #{rider.inspect}"
    @rider = rider
    @conflicts = conflicts
    @staffer = account.user

    now = now_unless_test
    next_monday = ( now.end_of_week + 1.day ).strftime("%-m/%-d")
    next_sunday = ( now.end_of_week + 7.days ).strftime("%-m/%-d")
    subject = "[SCHEDULING CONFLICT REQUEST] #{next_monday} - #{next_sunday}"
    
    mail(to: rider.email, subject: subject )
  end

  private

    def staffer_from account
      if account && account.user_type == 'Staffer' 
        account.user
      else
        Staffer.tess
      end
    end

end
