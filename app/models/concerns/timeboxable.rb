module Timeboxable
  extend ActiveSupport::Concern
  included do

    before_validation :set_period
    classy_enum_attr :period, allow_nil: true

    validates :start, :end, :period, presence: true
    validate :start_before_end, :less_than_24_hr

    def table_time
      self.start.strftime("%-m/%-d | %^a | %l:%M%p").strip << ' - ' << self.end.strftime("%l:%M%p").strip
    end

    def grid_time
      start_min = self.start.min == 0 ? '' : ":%M"
      end_min = self.start.min == 0 ? '' : "%M"

      self.start.strftime("%l").strip << start_min << "-" << self.end.strftime("%l").strip << end_min
    end

    def formal_date
      self.start.strftime("%B %e, %Y")
    end

    def short_date
      self.start.strftime("%-m/%-d/%y")
    end

    def very_short_date
      self.start.strftime("%-m/%-d")
    end

    def short_start_time
      self.start.strftime("%^a | %-m/%-d | %-l:%M %p")
    end

    def short_end_time
      self.end.strftime("%^a | %-m/%-d | %-l:%M %p")
    end

    def formal_start_time
      self.start.strftime("%b %e, %Y - %-l:%M %p")
    end

    def formal_start_time_with_day
      self.start.strftime("%^a | %b %e, %Y - %-l:%M %p")
    end

    def formal_end_time
      self.end.strftime("%b %e, %Y - %-l:%M %p")
    end

    def formal_end_time_with_day
      self.end.strftime("%^a | %b %e, %Y - %-l:%M %p")
    end

    def weekday
      self.start.strftime("%A")
    end

    def increment_by increment
      attrs = self.attributes.reject{ |k,v| k == 'id' }
      attrs[:start] = self.start + increment
      attrs[:end] = self.end + increment
      self.class.new(attrs)
    end

    def starts_before datetime
      self.start < datetime
    end

    def add_start_too_early_error datetime
      errors.add(:start, "can't be before #{datetime.strftime("%-m/%-d/%y")}")
    end

    def ends_after datetime
      self.end > datetime
    end

    def add_end_too_late_error datetime
      errors.add(:end, "can't be after #{datetime.strftime("%-m/%-d/%y")}")
    end

    private

      def set_period
        if self.end && self.start
          if self.end.hour <= 18 && ( self.start.hour >= 6 && self.start.hour < self.end.hour )
            self.period = :am
          elsif self.start.hour >= 16
            self.period = :pm
          else
            self.period = :double
          end
        end
      end
    
      def start_before_end
        if self.end.present? && start.present? && self.end <= start
          errors.add(:end, "can't be before start")
        end  
      end

      def less_than_24_hr
        if self.end.present? && start.present? && self.end - self.start > 24.hours
          errors.add(:base, 'Shifts cannot be longer than 24 hours')
        end
      end

  end

  module ClassMethods
    def self.matches_period(period, **options)
      if options.key? :restaurant
        rest = options[:restaurant]
        
      elsif options.key? :rider
      
      end
    end
  end
end