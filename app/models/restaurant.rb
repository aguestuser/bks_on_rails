# == Schema Information
#
# Table name: restaurants
#
#  id              :integer          not null, primary key
#  active          :boolean
#  status          :string(255)
#  description     :text
#  payment_method  :string(255)
#  pickup_required :boolean
#  created_at      :datetime
#  updated_at      :datetime
#

class Restaurant < ActiveRecord::Base
  include Contactable, RestaurantEnums
  has_many :managers, dependent: :destroy
  accepts_nested_attributes_for :managers, allow_destroy: true
  # accepts_nested_attributes_for :managers[:contact_info], allow_destroy: true
  has_one :work_arrangement, dependent: :destroy
  accepts_nested_attributes_for :work_arrangement

  validates :active , :status, :description, :payment_method, :pickup_required,
    presence: true
end
