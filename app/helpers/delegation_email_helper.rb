class DelegationEmailHelper
  attr_accessor :subject, :offering, :confirmation_request

  def initialize( shifts, now, type  )
    type = type ? type : type_from(now, shifts.first.start)
    plural = shifts.count > 1
    adj = type.to_s
    noun = noun_from type, plural

    @subject = subject_from adj, noun, shifts
    @offering = "We'd like to offer you the following #{adj} #{noun}:"
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
      str << "s" if plural
      str
    end

    def subject_from adj, noun, shifts
      "[" << adj.upcase << " " << noun.upcase << "] " << shift_descr_from(shifts)
    end

    def shift_descr_from shifts
      if shifts.count > 1
        shifts.map(&:table_time).join(', ')
      else
        shift = shifts.first
        "#{shift.table_time} @ #{shift.restaurant.name}"
      end
    end

    def conf_req_from noun, type
      conf_time = conf_time_from type
      "Please confirm whether you can work the #{noun} by #{conf_time}"
    end

    def conf_time_from type
      type == :weekly ? "12pm this Sunday" : "2pm tomorrow"
    end

end