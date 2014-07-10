# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Staffer < ActiveRecord::Base
  include User # ../concerns/contactable.rb
end
