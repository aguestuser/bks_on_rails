class RiderMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"

  def delegation_email rider, shifts, restaurants, account, type=nil
    require 'delegation_email_helper'

    @rider = rider
    @shifts = shifts
    @restaurants = restaurants
    @staffer = staffer_from account

    helper = DelegationEmailHelper.new(shifts, type, Time.zone.now)

    @salutation = "Dear #{rider.first_name}:"
    @offering = helper.offering
    @confirmation_request = helper.confirmation_request
    
    mail(to: rider.email, subject: helper.subject)
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
