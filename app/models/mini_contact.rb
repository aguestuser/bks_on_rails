# == Schema Information
#
# Table name: mini_contacts
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  phone         :string(255)
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class MiniContact < ActiveRecord::Base
  include Importable
  belongs_to :restaurant

  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  # VALID_PHONE = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  VALID_PHONE = /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/
  validates :phone, presence: true, 
              format: { with: VALID_PHONE }
end
