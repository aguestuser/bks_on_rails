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

    def noun_from type, plural
      str = type == :weekly ? "schedule" : "shift"
      str << "s" if plural && type != :weekly
      str
    end

    def subject_from adj, noun, shifts, type
      "[" << adj.upcase << " " << noun.upcase << "] " << shift_descr_from(shifts, type)
    end

    def shift_descr_from shifts, type
      case type
      when :weekly
        "-- PLEASE CONFIRM BY SUNDAY"
      when :extra
        '-- CONFIRMATION REQUIRED'
      when :emergency
        "-- SHIFT DETAILS ENCLOSED"
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