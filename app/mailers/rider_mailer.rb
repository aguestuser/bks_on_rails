class RiderMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"

  def delegation_email rider, shifts, account, now, type=nil
    require 'delegation_email_helper'

    @rider = rider
    @shifts = shifts
    @staffer = staffer_from account

    helper = DelegationEmailHelper.new(shifts, now, type)

    @salutation = "Dear #{rider.first_name}:"
    @offering = helper.offering
    @confirmation_request = helper.confirmation_request
    
    mail(to: rider.email, subject: helper.subject)

    # type = weekly ? :weekly : del_email_type_from now, shifts.first.start
    # plural = shifts.count > 1
    # adj = type.to_s.upcase
    # noun = del_noun_from type, plural

    # subject = del_subject_from adj, noun, @shifts
    # @salutation = "Dear #{rider.first_name}"
    # @offering = "We'd like to offer you the following #{adj} #{noun}:"
    # @confirmation_request = del_conf_req_from noun, type
    
    # mail(to: rider.email, subject: subject)
  end

  private

    def staffer_from account
      if account && account.user_type == 'Staffer' 
        account.user
      else
        Staffer.tess
      end
    end

    # delegation_email helpers

    # def del_email_type_from now, first_start
    #   time_gap = first_start - now
    #   if time_gap > 0 and time_gap <= 36.hours
    #     :emergency
    #   else
    #     :extra
    #   end
    # end

    # def del_noun_from type, plural
    #   str = type == :weekly ? "schedule" : "shift"
    #   str << "s" if plural      
    # end

    # def del_subject_from adj, noun, shifts
    #   "[" << adj.upcase << " " << noun.upcase << "]" << del_shift_descr_from shifts
    # end

    # def del_shift_descr_from shifts
    #   if shifts.count > 1
    #     shifts.map(&:table_time).join(', ')
    #   else
    #     shift = shifts.first
    #     "#{shift.table_time} @ #{shift.restaurant.name}"
    #   end
    # end

    # def del_conf_req_from noun, type
    #   conf_time = del_conf_time_from type
    #   "Please confirm whether you can work the #{noun} by #{conf_time}"
    # end

    # def del_conf_time_from type
    #   type == :weekly ? "12pm this Sunday" : "2pm tomorrow"
    # end

end
