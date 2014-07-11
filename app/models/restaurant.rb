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
  include Locatable, Equipable
  has_one :mini_contact, dependent: :destroy
    accepts_nested_attributes_for :mini_contact
  has_one :work_specification, dependent: :destroy
    accepts_nested_attributes_for :work_specification
  has_one :rider_payment_info, dependent: :destroy
    accepts_nested_attributes_for :rider_payment_info
  has_one :agency_payment_info, dependent: :destroy
    accepts_nested_attributes_for :agency_payment_info
  
  has_many :managers, dependent: :destroy
    accepts_nested_attributes_for :managers, allow_destroy: true
  has_many :shifts

  classy_enum_attr :status, enum: 'AccountStatus'


  validates :status, :brief, presence: true
  validates :active, inclusion: { in: [ true, false ] }
end
