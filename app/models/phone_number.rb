# == Schema Information
#
# Table name: phone_numbers
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  primary    :boolean
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class PhoneNumber < ActiveRecord::Base
  validates :type, presence: true
  validates :primary, presence: true
  VALID_NUMBER = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates :value, presence: true,
                    format: { with: VALID_NUMBER }
end
