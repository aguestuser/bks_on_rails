module Timeboxable
  extend ActiveSupport::Concern
  included do

    before_validation :set_period
    classy_enum_attr :period, allow_nil: true

    validates :start, :end, :period, presence: true
    validate :start_before_end

    def table_time
      self.start.strftime("%-m/%-d | %^a | %l:%M%p").strip << ' - ' << self.end.strftime("%l:%M%p").strip
    end

    def grid_time
      start_min = self.start.min == 0 ? '' : ":%M"
      end_min = self.start.min == 0 ? '' : "%M"

      self.start.strftime("%l").strip << start_min << "-" << self.end.strftime("%l").strip << end_min
    end

    def formal_time
      self.start.strftime("%B %e, %Y")
    end

    def short_time
      self.start.strftime("%-m/%-d/%y")
    end

    def weekday
      self.start.strftime("%A")
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