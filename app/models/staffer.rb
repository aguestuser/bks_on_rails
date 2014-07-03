# == Schema Information
#
# Table name: staffers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  title           :string(255)
#  contact_info_id :integer
#

class Staffer < ActiveRecord::Base
  #associations
  has_one :contact_info, as: :contactable

  #methods
  def email
    self.contact_info.email
  end

  def name
    self.contact_info.name
  end
end
