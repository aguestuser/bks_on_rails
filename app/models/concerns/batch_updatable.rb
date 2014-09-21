module BatchUpdatable
  extend ActiveSupport::Concern
  
  included do
  end

  module ClassMethods

    def clone records
      new_records = []
      records.each do |record|
        attrs = record.attributes.reject{ |k,v| k == 'id' || k == 'created_at' || k == 'updated_at' }
        new_records.push(self.new(attrs))
      end
      new_records
    end

    # def clone_batch_from_params param_hash
    #   attr_arr = self.attributes_from param_hash
    #   records = attr_arr.map do |attrs|
    #     attrs = attrs.reject{ |k,v| k == 'id' }
    #     self.new(attrs)
    #   end
    # end

    def batch_from_params param_arr
      attr_arr = param_arr.map{ |param_hash| self.attributes_from param_hash }
      records = attr_arr.map { |attrs| self.new( attrs ) }
    end

    def batch_create_ records
      errors = []
      records.each do |record|
        record.build_associations if record.respond_to?(:build_associations)
        errors.push(record.errors) unless record.save
      end
      errors
    end

    def batch_create attr_arr
      #input: Arr of attribute hashes
      #does: Saves shifts specified by attributes, returns errors if any
      #output: Arr of errors
      errors = []
      attr_arr.each do |attrs|
        record = self.new(parse_batch_attrs attrs)
        record.build_associations
        errors.push(record.errors) unless record.save
      end
      errors
    end

    def batch_update old_records, new_records
      # raise ( "NEW RECORD: " + new_records.inspect + "OLD Records: " + old_records.inspect )
      errors = []
      old_records.each_with_index do |old_record, i|
        attributes = new_records[i].attributes.reject{ |k,v| k == 'id' }
        record = old_record.class.find(old_record.id)
        
        errors.push( { error: record.errors, record: record } ) unless record.update(attributes)
      end
      errors
    end

    def attributes_from param_hash
      attrs = param_hash.to_h
      attrs.reject { |k,v| k == "id" }
      attrs["start"] = parse_date(attrs["start"]) if attrs["start"]
      attrs["end"] = parse_date(attrs["end"]) if attrs["end"]
      attrs
    end

    def parse_date d
      if d.class.name.include?('Time')
        d
      elsif d["year"]
        Time.zone.local( d["year"], d["month"], d["day"], d["hour"], d["minute"] )
      else
        d.to_datetime
      end
    end

    private


      
  end
end