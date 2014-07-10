# == Schema Information
#
# Table name: restaurants
#
#  id         :integer          not null, primary key
#  active     :boolean
#  status     :string(255)
#  brief      :text
#  created_at :datetime
#  updated_at :datetime
#

class Restaurant < ActiveRecord::Base
  include Contact, Locatable, Equipable
  has_one :work_specification
    accepts_nested_attributes_for :work_specification, allow_destroy: true
  has_one :rider_payment_info
    accepts_nested_attributes_for :rider_payment_info, allow_destroy: true
  has_one :agency_payment_info
    accepts_nested_attributes_for :agency_payment_info, allow_destroy: true
  
  has_many :managers, dependent: :destroy
    accepts_nested_attributes_for :managers, allow_destroy: true
  has_many :shifts

  classy_enum_attr :status, enum: 'AccountStatus'


  validates :status, :brief, presence: true
  validates :active, inclusion: { in: [ true, false ] }
end
