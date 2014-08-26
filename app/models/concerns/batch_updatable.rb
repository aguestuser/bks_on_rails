module BatchUpdatable
  extend ActiveSupport::Concern
  
  included do
  end

  module ClassMethods

    # def batch_create attr_arr
    #   errors = []
    #   attr_arr.each do |attrs|
    #     record = self.new( parse_batch_attrs attrs )
    #     record.build_associations
    #     errors.push(record.errors) unless record.save
    #   end
    #   errors
    # end

    def batch_create attr_arr
      #input: Arr of attributes
      #does: Saves shifts specified by attributes, returns errors if any
      #output: Arr of errors
      errors = []
      attr_arr.each_with_index do |attrs, i|
        record = self.new(parse_batch_attrs attrs)
        record.build_associations
        errors.push(record.errors) unless record.save
      end
      errors
    end

    def batch_update records, attr_arr
      records.each_with_index.inject([]) do |errors, (record, i)|
        attrs = parse_batch_attrs attr_arr[i]
        errors.push(record.errors) unless record.update(attrs)
        errors
      end
    end

    def parse_batch_attrs attrs
      attrs.reject! { |k,v| k == "id" }
      attrs["start"] = parse_date(attrs["start"]) if attrs["start"]
      attrs["end"] = parse_date(attrs["end"]) if attrs["end"]
      attrs.to_h
    end

    def parse_date d
      if d.class.name.include?('Time')
        d
      else
        Time.zone.local( d["year"], d["month"], d["day"], d["hour"], d["minute"] )
      end 
    end

    private


      
  end
end