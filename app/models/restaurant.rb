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
#  unedited   :boolean
#

class Restaurant < ActiveRecord::Base
  include Locatable, ImportableFirstClass, Exportable
  has_one :mini_contact, dependent: :destroy
    accepts_nested_attributes_for :mini_contact
  has_one :work_specification, dependent: :destroy
    accepts_nested_attributes_for :work_specification
  has_one :rider_payment_info, dependent: :destroy
    accepts_nested_attributes_for :rider_payment_info
  has_one :equipment_need, dependent: :destroy
    accepts_nested_attributes_for :equipment_need
  has_one :agency_payment_info, dependent: :destroy
    accepts_nested_attributes_for :agency_payment_info
  has_and_belongs_to_many :managers
    accepts_nested_attributes_for :managers, allow_destroy: true
  has_many :shifts

  classy_enum_attr :status, enum: 'AccountStatus'

  validates :status, :brief, presence: true
  validates :active, inclusion: { in: [ true, false ] }


  scope :with_shifts_this_week, -> { 
    joins(:shifts)
    .where(
      "start > :start_t AND start < :end_t", 
      { 
        start_t: (Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now).beginning_of_week,
        end_t: (Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now).beginning_of_week + 1.week
      }
    )
    .joins(:mini_contact)
    .order("mini_contacts.name asc") 
    .to_a.uniq
  }

  EXPORT_COLUMNS = [ 'id', 'active' ]
  EXPORT_HEADERS = EXPORT_COLUMNS


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

  def self.select_options
    Restaurant.all.joins(:mini_contact).order("mini_contacts.name asc").map{ |r| [ r.name, r.id ] }
  end

  def self.multiselect_options
    [ [ '* All Restaurants', 'all' ] ] + self.select_options
  end

  def self.search params
    if params[:search]
      base = self.joins(:mini_contact).where('mini_contacts.name ILIKE ?', "%#{params[:search]}%")
    else
      base = self.joins(:mini_contact)
    end
    base.order('mini_contacts.name asc').page(params[:page])
  end

  private

  def parse_export_values attrs
    attrs
  end
  
  def self.import_children path
    #input: none
    #output Hash of Arrays of Restaurant children 
      #{ minicontacts: Arr of MiniContacts, managers: Arr of Managers, ...}
    { 
      mini_contacts: MiniContact.import( "#{path}mini_contacts.csv" ),
      managers: Manager.import( "#{path}managers/managers.csv", "#{path}managers/accounts.csv", "#{path}managers/contacts.csv" ),
      work_specifications: WorkSpecification.import( "#{path}work_specifications.csv" ),
      rider_payments_infos: RiderPaymentInfo.import( "#{path}rider_payment_infos.csv" ),
      agency_payment_infos: AgencyPaymentInfo.import( "#{path}agency_payment_infos.csv" ),
      equipment_needs: EquipmentNeed.import( "#{path}equipment_needs.csv" ),
      locations: Location.import( "#{path}locations.csv" )
    }
  end

  def self.import_attrs_from row_hash, c, i
    #input: Hash of Restaurant attributes, Hash of Hashes of attributes for children of Restaurants, Int (index)
    #output: Hash of Hashes of attributes for Restaurant *and* its children
    row_hash
      .reject{ |k,v| k == 'id' }
      .merge( {
        mini_contact: c[:mini_contacts][i],
        managers: [ c[:managers][i] ],
        work_specification: c[:work_specifications][i],
        rider_payment_info: c[:rider_payments_infos][i],
        agency_payment_info: c[:agency_payment_infos][i],
        equipment_need: c[:equipment_needs][i],
        location: c[:locations][i]
      } )
  end

  def self.child_export_headers
    [ 'name', 'address', 'lat', 'lng' ]
  end

  def self.child_export_cells_from restaurant
    l = restaurant.location
    [ 
      restaurant.mini_contact.name, 
      l.address,
      l.lat,
      l.lng
    ]
  end

end
