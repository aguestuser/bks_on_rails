# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Staffer < ActiveRecord::Base
  include User, Contactable # ../concerns/user.rb

  scope :tess, -> { joins(:contact).where("contacts.email = ?", "tess@bkshift.com").first }
end
