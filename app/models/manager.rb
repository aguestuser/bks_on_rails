# == Schema Information
#
# Table name: managers
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Manager < ActiveRecord::Base
  belongs_to :restaurant
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
