module BatchUpdatable
  extend ActiveSupport::Concern
  
  included do
  end

  module ClassMethods

    def batch_update records, attr_arr
      errors = []
      records.each_with_index do |record, i|
        attrs = parse_batch_attrs attr_arr[i]
        unless record.update(attrs)
          errors.push record.errors
        end
      end
      errors
    end

    private

      def parse_batch_attrs attrs
        attrs.reject! { |k,v| k == "id" }
        attrs["start"] = parse_date attrs["start"] if attrs["start"]
        attrs["end"] = parse_date attrs["end"] if attrs["end"]
        attrs.to_h
      end

      def parse_date d
        Time.zone.local( d["year"], d["month"], d["day"], d["hour"], d["minute"] )
      end
      
  end
end