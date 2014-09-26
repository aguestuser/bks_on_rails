module TestTime
  extend ActiveSupport::Concern
  included do
    
    private
      def now_unless_test
        Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now
      end
  end

  module ClassMethods
  end
end