module Contactable
  extend ActiveSupport::Concern

  included do # instance methods
    #associations
    has_one :contact, as: :contactable, dependent: :destroy
      accepts_nested_attributes_for :contact
  end

  def name
    self.contact.name
  end

  def first_name
    match = self.contact.name.match(/^[A-Z](\w|\.)*\s/)
    match ? match[0].strip : self.contact.name 
  end

  def short_name
    self.contact.name.match(/^[A-Z](\w|\.)*\s[A-Z]/)[0]
  end

  def title
    self.contact.title
  end

  def email
    self.contact.email
  end

  def phone
    self.contact.phone
  end

  module ClassMethods
  end
end










