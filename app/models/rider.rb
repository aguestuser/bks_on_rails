# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#  notes      :text
#

class Rider < ActiveRecord::Base
  include User, Contactable, Equipable, Locatable, ImportableFirstClass, Exportable # app/models/concerns/

  #constants
  EXPORT_COLUMNS = [ 'id', 'active' ]
  EXPORT_HEADERS = EXPORT_COLUMNS

  #associations
  has_one :qualification_set, dependent: :destroy
    accepts_nested_attributes_for :qualification_set
  has_one  :skill_set, dependent: :destroy
    accepts_nested_attributes_for :skill_set
  has_one :rider_rating, dependent: :destroy
    accepts_nested_attributes_for :rider_rating

  has_one :toe_consent
  has_many :assignments
  has_many :shifts, through: :assignments
  has_many :conflicts

  #validations
  validates :active, inclusion: { in: [ true, false ] }

  #scopes
  scope :testy, -> { includes(:contact).where("contacts.email = ?", "bkshifttester@gmail.com").first }
  scope :active, -> { includes(:contact).where(active: true).order("contacts.name asc") }
  scope :inactive, -> { includes(:contact).where(active: false).order("contacts.name asc") }

  #callbacks
  before_create { contact.name = contact.name.split.map(&:capitalize).join(' ') }

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

  def has_toe_consent?
    self.toe_consent
  end

  #class methods
  def self.select_options
    Rider.all.joins(:contact).where("active = ?", :true).order("contacts.name asc").map{ |r| [ r.name, r.id ] }
  end

  def self.multiselect_options
    [ [ '* All Riders', 'all' ], [ '--', 0] ] + self.select_options
  end

  def self.search params
    if params[:search]
      base = self.joins(:contact).where('contacts.name ILIKE ?', "%#{params[:search]}%")
    else
      base = self.joins(:contact)
    end
    base.order('contacts.name asc').page(params[:page])
  end

  def self.request_conflicts sender_account, now
    riders = self.active
    # now = now_unless_test
    this_monday = now.beginning_of_week
    next_monday = this_monday + 1.week

    rider_conflicts = RiderConflicts.new( riders, this_monday ).increment_week
    email_alert = self.email_conflict_requests rider_conflicts, next_monday, sender_account
  end

  def self.email_conflict_requests rider_conflicts, week_start, sender_account
    #input: RiderConflicts, Datetime, Account
    #output: Str (empty if no emails sent, email alert if emails sent)
    count = 0
    rider_conflicts.arr.each do |hash|
      # if count > 0 && count % 50 == 0
      #   puts ">>> SLEEPING"
      #   sleep 180
      # end
      RiderMailer.request_conflicts(hash[:rider], hash[:conflicts], week_start, sender_account).deliver
      count += 1
      # puts ">>>>>#{count} EMAILS SENT"
    end

    alert = count > 0 ? "#{count} conflict requests sent" : ""
  end

  private

    def parse_export_values attrs
      attrs
    end

    def self.import_children path
      #input: none
      #output Hash of Arrays of Rider children
        #{ accounts: Arr of Accounts, contacts: Arr of Contacts,  ...}
      {
        accounts: Account.import( "#{path}accounts.csv" ),
        contacts: Contact.import( "#{path}contacts.csv" ),
        qualification_sets: QualificationSet.import( "#{path}qualification_sets.csv" ),
        skill_sets: SkillSet.import( "#{path}skill_sets.csv" ),
        rider_ratings: RiderRating.import( "#{path}rider_ratings.csv" ) ,
        equipment_sets: EquipmentSet.import( "#{path}equipment_sets.csv" ),
        locations: Location.import( "#{path}locations.csv" )
      }
    end

    def self.import_attrs_from row_hash, c, i
      #input: Hash of Restaurant attributes, Hash of Hashes of attributes for children of Restaurants, Int (index)
      #output: Hash of Hashes of attributes for Restaurant *and* its children
      row_hash
        .reject{ |k,v| k == 'id' }
        .merge( {
          account: c[:accounts][i],
          contact: c[:contacts][i],
          qualification_set: c[:qualification_sets][i],
          skill_set: c[:skill_sets][i],
          rider_rating: c[:rider_ratings][i],
          equipment_set: c[:equipment_sets][i],
          location: c[:locations][i]
        } )
    end

    def self.child_export_headers
      [ 'name', 'email' ]
    end

    def self.child_export_cells_from rider
      [ rider.name, rider.email ]
    end

end
