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
  include Contactable
  has_many :managers, dependent: :destroy
    accepts_nested_attributes_for :managers, allow_destroy: true
  has_one :work_arrangement, dependent: :destroy
    accepts_nested_attributes_for :work_arrangement
  has_many :shifts

  classy_enum_attr :status, enum: 'AccountStatus'
  classy_enum_attr :agency_payment_method 

  validates :status, :description, :agency_payment_method, 
    presence: true
end
