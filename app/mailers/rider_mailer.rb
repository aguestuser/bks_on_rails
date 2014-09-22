class RiderMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"
  helper_method :protect_against_forgery?
  
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

  def request_conflicts rider, conflicts, week_start, account
    # puts ">>>> rider: #{rider.inspect}"

    @rider = rider
    @conflicts = conflicts
    @staffer = account.user
    
    @next_week_start = week_start
    @this_week_start = @next_week_start - 1.week
    @new_batch_query = { rider_id: rider.id, week_start: @next_week_start }.to_query

    next_monday = ( @next_week_start ).strftime("%-m/%-d")
    next_sunday = ( @next_week_start + 6.days ).strftime("%-m/%-d")

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

    def protect_against_forgery?
      false
    end
      
end
