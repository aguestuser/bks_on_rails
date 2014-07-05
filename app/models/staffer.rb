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

end
