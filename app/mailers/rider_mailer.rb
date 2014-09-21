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

  def conflicts_request rider, conflicts account
    # puts ">>>> rider: #{rider.inspect}"
    @rider = rider
    @conflicts = conflicts
    @staffer = account.user
    
    @next_week_start = conflicts.first.beginning_of_week
    @this_week_start = @next_week_start - 1.week
    @clone_query = { conflicts: conflicts }.to_query
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

end
