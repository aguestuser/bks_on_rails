module Hashable
  module ClassMethods
    
  end
  
  module InstanceMethods
    def to_hash
      hash = {}
      self.instance_variables.each do |var|
        key = var.to_s.delete '@'
        value = get_value_from var
        hash[key] = value
      end
      hash
    end

    private

      def get_value_from var
        value = self.instance_variable_get var
        get_base_value_from value
      end

      def get_base_value_from value 
        if value.class.name == 'Array' 
          base_value = value.map{ |value| get_base_value_from value } # RECURSE
        elsif value.class.name == 'Hash'
          base_value = {} 
          value.each { |k,v| base_value[k] = get_base_value_from v }# RECURSE
          base_value
        else 
          value # BASE CASE
        end
      end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end