# == Schema Information
#
# Table name: staffers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  contact_info_id :integer
#

class Staffer < ActiveRecord::Base
  #associations
  has_one :contact_info, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact_info

  #class methods
  def self.find_by_email(email)
    contact_info = ContactInfo.find_by(email: email)
    Staffer.find(contact_info.contactable.id)
  end

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

end
