class DelegationEmailHelper
  attr_accessor :subject, :offering, :confirmation_request

  def initialize shifts, urgency, email_type 

    plural = shifts.count > 1
    adj = urgency.to_s
    noun = noun_from urgency, plural

    @subject = subject_from adj, noun, urgency, email_type
    @offering = offering_from adj, noun, email_type
    @confirmation_request = conf_req_from noun, urgency, email_type 

  end

  private

    def noun_from urgency, plural
      str = urgency == :weekly ? "schedule" : "shift"
      str << "s" if plural && urgency != :weekly
      str
    end

    def subject_from adj, noun, urgency, email_type
      #input: 
        # Enum Str { 'Weekly', 'Emergency', 'Extra' }, 
        # Enum Str { 'Shift', 'Shifts', 'Schedule' }, 
        # Enum Sym { :weekly, :extra, :emergency } , 
        # Enum Sym { :delegation, :confirmation }, 
      "[" << adj.upcase << " " << noun.upcase << "] " << imperative_from(urgency, email_type)
    end

    def imperative_from urgency, email_type
      if urgency == :weekly
        "-- PLEASE CONFIRM BY SUNDAY"
      else
        case email_type
        when :delegation
          "-- CONFIRMATION REQUIRED"
        when :confirmation
          "-- SHIFT DETAILS ENCLOSED"
        end
      end
    end

    def offering_from adj, noun, email_type
      offer_prefix = offer_prefix_from email_type
      "#{offer_prefix} #{adj} #{noun}:"
    end

    def offer_prefix_from email_type
      if email_type == :confirmation
        "As per our conversation, you are confirmed for the following"
      else 
        "We'd like to offer you the following"
      end
    end

    def conf_req_from noun, urgency, email_type
      if email_type == :confirmation
        "Have a great shift!"
      else 
        conf_time = conf_time_from urgency
        "Please confirm whether you can work the #{noun} by #{conf_time}"
      end
    end

    def conf_time_from urgency
      urgency == :weekly ? "12pm this Sunday" : "2pm tomorrow"
    end

end