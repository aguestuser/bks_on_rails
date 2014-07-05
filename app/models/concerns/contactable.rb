module Contactable
  extend ActiveSupport::Concern

  included do
    has_one :contact_info, as: :contactable, dependent: :destroy
    accepts_nested_attributes_for :contact_info    
  end
  
  module ClassMethods
    def find_by_email(email)
      contact_info = ContactInfo.find_by(email: email)
      Staffer.find(contact_info.contactable.id)
    end
  end  
end

