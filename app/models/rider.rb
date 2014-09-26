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

  validates :active, inclusion: { in: [ true, false ] }

  scope :testy, -> { joins(:contact).where("contacts.email = ?", "bkshifttester@gmail.com").first }
  scope :active, -> { joins(:contact).where(active: true).order("contacts.name asc") }
  scope :inactive, -> { joins(:contact).where(active: false).order("contacts.name asc") }
  
#public methods
  def name
    self.contact.name
  end

  def shifts_on date #input: date obj, #output Arr of Assignments (possibly empty)
    self.shifts.where( start: (date.beginning_of_day..date.end_of_day) )
  end

  def conflicts_on date #input: date obj, #output Arr of Conflicts (possibly empty)
    self.conflicts.where( start: (date.beginning_of_day..date.end_of_day) )
  end

  def conflicts_between start_t, end_t
    #input: Rider(self/implicit), Datetiem, Datetime
    #does: builds an array of conflicts belonging to rider within date range btw/ start_t and end_t
    #output: Arr
    conflicts = self.conflicts
      .where( "start > :start AND start < :end", { start: start_t, :end => end_t } )
      .order("start asc")
  end

  #class methods
  def Rider.select_options
    Rider.all.joins(:contact).order("contacts.name asc").map{ |r| [ r.name, r.id ] }
  end

  def Rider.email_conflict_requests rider_conflicts, week_start, account
    #input: RiderConflicts, Datetime, Account
    #output: Str (empty if no emails sent, email alert if emails sent)
    count = 0
    rider_conflicts.arr.each do |hash| 
      RiderMailer.request_conflicts(hash[:rider], hash[:conflicts], week_start, account).deliver
      count += 1
    end
    
    alert = count > 0 ? "#{count} conflict requests successfully sent" : ""
  end

end
