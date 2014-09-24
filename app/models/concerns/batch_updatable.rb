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

    def batch_from_params param_arr
      #input: Arr of Param Hashes (params[:<record_type>]) of type:
        # [ { 'id': Str, 'restaurant_id': Str, ... }, { 'id': Str, 'restaurant_id': Str, ... }, ... ]
      #output: Arr of records of whatever class calls this method
      if param_arr.nil?
        []
      else
        attr_arr = param_arr.map{ |param_hash| self.attributes_from param_hash }
        records = attr_arr.map { |attrs| self.new( attrs ) }
      end
    end

    def batch_create records
      #input Arr of unsaved records
      #does: builds associated records & attempts save for each record, returns array of errors
      #output: Arr of Errors
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
      #input: Arr of saved records (of class self), Arr of unsaved records (of class self)
      #does: updates saved records with attributes from unsaved records, attempts save, returns array of errors
      #output: Arr of Errors
      errors = []
      old_records.each_with_index do |old_record, i|
        attributes = new_records[i].attributes.reject{ |k,v| k == 'id' }
        record = old_record.class.find(old_record.id)
        
        errors.push( { error: record.errors, record: record } ) unless record.update(attributes)
      end
      errors
    end

    def attributes_from param_hash
      #input: Hash of type { 'id': Str, 'start': Str ... }
      #does: parses hash to well-formed (savable) attribute hash
      #output: Hash of type { id: Int, start: Datetime, ... }
      attrs = param_hash.to_h
      attrs.reject { |k,v| k == "id" }
      attrs["start"] = parse_date(attrs["start"]) if attrs["start"]
      attrs["end"] = parse_date(attrs["end"]) if attrs["end"]
      attrs
    end

    def parse_date d
      #input: DateTime OR Hash of Strings OR Str
      #does: parses param version of datetime of unknown type into well-formed Datetime obj
      #output: DateTime
      if d.class.name.include?('Time')
        d
      elsif d["year"]
        Time.zone.local( d["year"], d["month"], d["day"], d["hour"], d["minute"] )
      else
        Time.zone.parse d
      end
    end

    private


      
  end
end