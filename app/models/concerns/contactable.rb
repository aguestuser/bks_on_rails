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










