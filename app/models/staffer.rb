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
