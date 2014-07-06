module Contactable
  extend ActiveSupport::Concern


  included do
    before_validation :get_contactable_class
    has_one :contact_info, as: :contactable, dependent: :destroy
    accepts_nested_attributes_for :contact_info

    #methods

    def name
      self.contact_info.name
    end

    def phone
      self.contact_info.phone
    end

    def email # i could DRY up this and the title method, no?
      begin
        if @klass != Restaurant
          self.contact_info.email
        else
          raise Exception, "You tried to find a restaurant by its email. Restaurants don't have emails, silly!"
        end        
      rescue Exception => e
        #do something here to handle error
      end
    end

    def title
      begin
        if @klass != Restaurant
          self.contact_info.title
        else
          raise Exception, "You tried to find a restaurant by its title. Restaurants don't have titles, silly!"
        end        
      rescue Exception => e
        #do something here to handle error
      end
    end

    private       
      def get_contactable_class
        @klass = self.class.name.constantize
      end
  
  end
  
  module ClassMethods
    def find_by_email(email)
      contact_info = ContactInfo.find_by(email: email)
      klass = name.constantize
      klass.find(contact_info.contactable.id)
    end
  end  
end

