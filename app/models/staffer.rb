# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Staffer < ActiveRecord::Base
  include Contactable

  #methods
  def email
    self.contact_info.email
  end

  def name
    self.contact_info.name
  end
  
  def title
    self.contact_info.title
  end

  #class methods
  def find_by_email(email)
    contact_info = ContactInfo.find_by(email: email)
    Staffer.find(contact_info.contactable.id)
  end

end
