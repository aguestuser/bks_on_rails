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

  #public methods

  def name
    self.mini_contact.name
  end

  def phone
    self.mini_contact.phone
  end

  def shifts_between start_t, end_t
    shifts = self.shifts
      .where( "start > :start AND start < :end", { start: start_t, :end => end_t } )
      .order("start asc")
  end

  #class methods

  def Restaurant.select_options
    Restaurant.all.joins(:mini_contact).order("mini_contacts.name asc").map{ |r| [ r.name, r.id ] }
  end
end
