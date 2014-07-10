module Contactable
  extend ActiveSupport::Concern


  included do
    has_one :contact_info, as: :contact, dependent: :destroy
    accepts_nested_attributes_for :contact_info

    #methods

    def name
      self.contact_info.name
    end

    def phone
      self.contact_info.phone
    end

    private       
      # def get_contactable_class
      #   @klass = self.class.name.constantize
      # end
  
  end
  
  module ClassMethods
  end  
end

