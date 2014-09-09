class DelegationEmailHelper
  attr_accessor :subject, :offering, :confirmation_request

  def initialize( shifts, type, now  )
    # type = type ? type : type_from(now, shifts.first.start)
    plural = shifts.count > 1
    adj = type.to_s
    noun = noun_from type, plural
    

    @subject = subject_from adj, noun, shifts, type
    @offering = offering_from adj, noun, type
    @confirmation_request = conf_req_from noun, type

  end

  private

    def type_from now, first_start
      time_gap = first_start - now
      if time_gap > 0 and time_gap <= 36.hours
        :emergency
      elsif time_gap > 36.hours
        :extra
      else
        raise "You are trying to delegate a shift that already took place"
      end
    end

    def noun_from type, plural
      str = type == :weekly ? "schedule" : "shift"
      str << "s" if plural && type != :weekly
      str
    end

    def subject_from adj, noun, shifts, type
      "[" << adj.upcase << " " << noun.upcase << "] " << shift_descr_from(shifts, type)
    end

    def shift_descr_from shifts, type
      if type == :weekly
        "-- PLEASE CONFIRM BY SUNDAY"
      else 
        if shifts.count > 1
          shifts.map(&:very_short_time).join(', ')
        else
          shift = shifts.first
          "#{shift.very_short_time} @ #{shift.restaurant.name}"
        end
      end
    end

    def offering_from adj, noun, type
      offer_prefix = offer_prefix_from type
      "#{offer_prefix} #{adj} #{noun}:"
    end

    def offer_prefix_from type
      if type == :emergency
        "As per our conversation, you are confirmed for the following"
      else 
        "We'd like to offer you the following"
      end
    end

    def conf_req_from noun, type
      if type == :emergency
        "Have a great shift!"
      else 
        conf_time = conf_time_from type
        "Please confirm whether you can work the #{noun} by #{conf_time}"
      end
    end

    def conf_time_from type
      type == :weekly ? "12pm this Sunday" : "2pm tomorrow"
    end

end