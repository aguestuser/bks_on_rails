# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Rider < ActiveRecord::Base
  include User, Contactable, Equipable, Locatable # app/models/concerns/

  #nested attributes
  has_one :qualification_set, dependent: :destroy
    accepts_nested_attributes_for :qualification_set
  has_one  :skill_set, dependent: :destroy
    accepts_nested_attributes_for :skill_set
  has_one :rider_rating, dependent: :destroy
    accepts_nested_attributes_for :rider_rating
  
  #associations
  has_many :assignments
  has_many :shifts, through: :assignments
  has_many :conflicts 

  validates :active, 
    presence: true,
    inclusion: { in: [ true, false ] }

  scope :testy, -> { joins(:contact).where("contacts.email = ?", "bkshifttester@gmail.com").first }
  scope :active, -> { joins(:contact).where(active: true).order("contacts.name asc") }
  scope :inactive, -> { joins(:contact).where(active: false).order("contacts.name asc") }

#public methods
  def name
    self.contact.name
  end

  def shifts_on(date) #input: date obj, #output Arr of Assignments (possibly empty)
    self.shifts.where( start: (date.beginning_of_day..date.end_of_day) )
  end

  def conflicts_on(date) #input: date obj, #output Arr of Conflicts (possibly empty)
    self.conflicts.where( start: (date.beginning_of_day..date.end_of_day) )
  end

  #class methods
  def Rider.select_options
    Rider.all.joins(:contact).order("contacts.name asc").map{ |r| [ r.name, r.id ] }
  end

end
