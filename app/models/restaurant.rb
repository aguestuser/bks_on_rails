# == Schema Information
#
# Table name: restaurants
#
#  id                    :integer          not null, primary key
#  active                :boolean
#  status                :string(255)
#  description           :text
#  agency_payment_method :string(255)
#  pickup_required       :boolean
#  created_at            :datetime
#  updated_at            :datetime
#

class Restaurant < ActiveRecord::Base
  include Contact, Locatable
  has_many :managers, dependent: :destroy
    accepts_nested_attributes_for :managers, allow_destroy: true
  has_one :work_requirements_info
    accepts_nested_attributes_for :work_requirements_info, allow_destroy: true
  has_one :rider_payment_info
    accepts_nested_attributes_for :rider_payment_info, allow_destroy: true
  has_one :agency_payment_info
    accepts_nested_attributes_for :agency_payment_info, allow_destroy: true
  has_one :equipment_set, as: :equipable
  has_many :shifts

  classy_enum_attr :status, enum: 'AccountStatus'
  classy_enum_attr :agency_payment_method 

  validates :active, :status, :description, :agency_payment_method, 
    presence: true
end
