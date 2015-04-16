class RiderMailer < ActionMailer::Base
  include RemoteRoot
  default from: "'BK SHIFT' <brooklynshift@gmail.com>"

  helper_method :protect_against_forgery?

  def delegation_email sender_account, rider, urgency, email_type, shifts, restaurants
    #input: Account, Rider, Symbol, Symbol, Arr of Shifs, Arr of Restaurants
    require 'delegation_email_helper'

    @rider = rider
    @shifts = shifts
    @restaurants = restaurants
    @staffer = sender_account.user #, staffer_from account

    helper = DelegationEmailHelper.new shifts, urgency, email_type

    @offering = helper.offering
    @confirmation_request = helper.confirmation_request

    mail(to: rider.full_email, subject: helper.subject)
  end

  def request_conflicts rider, conflicts, week_start, account

    @rider = rider
    @conflicts = conflicts
    @staffer = account.user

    @next_week_start = week_start
    @this_week_start = @next_week_start - 1.week

    query = { rider_id: @rider.id, week_start: @this_week_start }.to_query
    @link = ENV["ROOT"] + "conflict/preview_batch?#{query}"

    next_monday = ( @next_week_start ).strftime("%-m/%-d")
    next_sunday = ( @next_week_start + 6.days ).strftime("%-m/%-d")
    subject = "[SCHEDULING CONFLICT REQUEST] #{next_monday} - #{next_sunday}"

    mail(to: rider.full_email, subject: subject )
  end

  def welcome rider, account
    @rider = rider
    @toe_link = ENV["ROOT"][0..-2] + new_rider_toe_consent_path(@rider)
    @staffer = account.user

    mail(to: "'#{@rider.name}' <#{rider.email}>", subject: "WELCOME TO BK SHIFT")
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
