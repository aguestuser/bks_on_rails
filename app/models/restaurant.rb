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
  include Locatable
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
  has_many :managers, dependent: :destroy
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

  def Restaurant.import
    path = Rails.env.test? ? 'app/io/import/sample/restaurants/' : 'app/io/import/restaurants/'
    children = Restaurant.import_children path
      # puts ">>> children"
      # pp children
    results = Restaurant.import_self path, children

    puts "IMPORTED: #{results[:num_recs]} restaurants"
    puts "ERRORS: #{results[:num_errors]}"
    if results[:errors].any?
      puts "ERROR IDS: #{results[:error_ids].join(', ')}"
      puts "ERRORS MESSAGES: "
      pp results[:errors]
    else 
      puts "ID DISCREPANCIES:"
      pp results[:id_discrepancies]
    end
  end

  def Restaurant.import_children path
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

  def Restaurant.import_self path, children
    r_path = "#{path}restaurants.csv"
    results = { num_recs: ( CSV.read(r_path).count - 1 ), num_errors: 0, error_ids: [], errors: [], id_discrepancies: {} }

    CSV.foreach(r_path, headers: true) do |row|
      i = $. - 2 # $. returns the INPUT_LINE_NUMBER, subtracting one produces index number
      row_hash = row.to_hash
      old_id = row_hash['id']    
      attrs = Restaurant.import_attrs_from row_hash, children, i
        # puts ">>> ATTRS"
        # pp attrs
      restaurant = Restaurant.new attrs

      if restaurant.save
        results[:id_discrepancies][i+1] = restaurant.id if i+1 != restaurant.id
      else
        results[:num_recs] -= 1
        results[:num_errors] += 1
        results[:error_ids].push(old_id)
        results[:errors].push(restaurant.errors)
      end
    end
    results
  end

  def Restaurant.import_attrs_from row_hash, c, i
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


  private


end
