
##
# DOMAIN MODEL FOR BKS SHIFT ON RAILS

# AUTHOR:
# Austin Guest, 2014

# LICENSE:
#   This is free software licensed under the GNU General Public License v3. 
#   See http://www.gnu.org/licenses/gpl-3.0.txt for terms of the license.
##

require 'date'

class Main #is there any way to reflect the cateogry groupings I have accomplished through commenting below in a way that is reflected in the structure of the code? Is that necessary?
  #users/entities
  @staffers # arr of Staffers
  @restaurants # arr of Restaurants
  @owners # arr of Owners
  @managers # arr of Managers
  @riders # arr of Riders
  @edits # arr of Edits
  #scheduling
  @requests # arr of Requests
  @shifts # arr of Assignments
  @conflicts # arr of Conflicts
  @assignments # arr of Assignments
  @assignment_actions # arr of Assignment_Actions
  @assignment_responses # arr of Assignment_Responses
  #calendar
  @weeks # arr of Weeks
  @time_windows # arr of Time_Windows
  @calendars # arr of Calendars
  @events # arr of Events
  #mapping 
  @locations # arr of Locations (necessary???)
  #communication
  @schedule_emails # arr of Schedule_Emails (would it make more sense to group this with other scheduling attributes?)
  @invoice_emails # arr of Invoice_Emails (would it make more sense to group this with other billing attributes?)
  #billing
  @payments # arr of Payments
  @invoices # arr of Invoices

end

# class PhoneNumber
#   @type # Phone_Types::ENUM
#   @primary # bool
#   @value # str
# end

# class Phone_Types
#   include Ruby::Enum
#   define :WORK, 'Work'
#   define :CELL, 'Cell'
#   define :HOME, 'Home'
#   define :PARENT, 'Parent'
#   define :PARTNER, 'Partner'
# end

# class Email_Address
#   @primary # bool
#   @value # str
# end

# class Email_Address_Types
#   include Ruby::Enum
#   define :WORK, 'Work'
#   define :PERSONAL, 'Personal'
# end



class Boroughs 
  manhattan: 'Manhtattan'
  brooklyn: 'Brooklyn'
  queens: 'Queens'
  bronx: 'Bronx'
  staten_island: 'Staten Island'
end

class Neighborhoods # note: will need to dynamically update this set of enums as we add more neighborhoods
  include Ruby::Enum
  define :PARK_SLOPE, 'Park Slope'
  define :FORT_GREENE, 'Fort Greene'
  define :PROSPECT_HEIGHTS, 'Prospect Heights'
  define :GOWANUS, 'Gowanus'
  define :BOERUM_HILL, 'Boerum Hill'
  define :FINANCIAL_DISTRICT, 'Financial District'
  define :LOWER_EAST_SIDE, 'Lower East Side'
  define :TRIBECA, 'Tribeca'
  define :CHELSEA, 'Chelsea'
  define :EAST_VILLAGE, 'East Village'
  define :WEST_VILLAGE, 'West Village'
  define :MIDTOWN_EAST, 'Midtown East'
  define :MIDTOWN_WEST, 'Midtown West'
  define :EAST_HARLEM, 'East Harlem'
  define :LONG_ISLAND_CITY, 'Long Island City'
end 

class Staffer
  include User
end

class Manager
  include User
  belongs_to :restaurant

  has_one :contact_info, as: :contact
  has_one :location, as: :locatable
end

class Account
  belongs_to :user, polymorpous: true
  has_one :contact

  @password_hash # str
end

class Contact
  belongs_to :account
  @name # Str (min length 3)
  @title # str (min length 3)
  @phone # Str (matches VALID_)
  @email # Str (w/ regex validation)
end

class Location
  @address # str
  @borough # Boroughs::ENUM
  @neighborhood # Neighborhoods::ENUM
  # @lat # :decimal, {:precision=>10, :scale=>6}
  # @lng # str
end


class Restaurant
  # include Contact, Locatable
  include Locatable
  has_one :short_contact_info
  has_many :managers # Manager
  # has_one :work_rule_set, replace with:
  has_one :work_specification
  has_one :rider_payment_info
  has_one :agency_payment_info
  has_one :equipment_set, as: :equipable

  has_many :shifts # Shift 
  # has_one :balance # Balance
  # has_one :restaurant_rating 
  
  @active #bool
  @status # RestaurantStatuses::Enum
  @brief # Text
  # @description # text
  # @payment_method # PaymentMethods::Enum
  # @pickup_required #bool

end

class ShortContactInfo
  @name # str ( btw 3 & 30 chars)
  @phone # str (VALID_PHONE)
end

class AgencyPaymentInfo
  :belongs_to :restaurant
  @method # AgencyPaymentMethod::Enum
  @pickup_required # boolean
end

class RiderPaymentInfo
  :belongs_to :restaurant
  @method #RiderPaymentMethod::Enum
  @rate #str
  @shift_meal #bool
  @cash_out_tips #bool
  # @rider_on_premises #bool
end

class WorkSpecification
  belongs_to :restaurant

  @zone #str
  @daytime_volume #str
  @evening_volume #str
  @extra_work #bool
  @extra_work_description # str

end

class EquipmentSet
  belongs_to :equipable, polymorpous: true
  
  @bike # bool
  @lock # bool
  @helmet #bool
  @rack # bool
  @bag # bool
  @heated_bag # bool
  @cell_phone # bool
  @smart_phone # bool
end

class Owner < User
  @restaurant # Restaurant
  TITLE #constant (title of any owner will always be "Owner" -- how do I specify that in Ruby syntax?)
end

class Manager < User
  belongs_to :restaurant # Restaurant
  has_one :contact_info # ContactInfo
end

class Rider
  include User, Equipable, Locatable (has_one :account, has_one :equipment_set, has_one: location)
  has_one :qualification_set
  has_one :skill_set
  has_one :rider_rating

  @active #bool

  # @hire_date # Date
  # @start_date # Date
  # @termination_date # Date
end

class QualificationSet
  @experience # text
  @geography # text
  @hiring_assessment # text 
  # @skills # Arr of Skills::Enum [:bike_repair, :fix_flats, :early_morning, :pizza]
end

class SkillSet
  @bike_repair # bool
  @fix_flats # bool
  @early_morning #bool
  @pizza #bool
end

class RiderRating < Rider_Assets
  @initial_points # int
  @likeability # int
  @reliability # int
  @speed #int
  # @punctuality # int
  @points # int
end



class Shift 
  belongs_to :restaurant # Restaurant
  @start # Date
  @end # Date
  @period # Periods::ENUM
  @urgency #Urgencies::ENUM
  @billing_rate #Billing_Rates::ENUM
  # @notes # str
  
  # @time_windows # arr of Time_Windows
  # @event # Event 
  # @assignment # Assignment
  # @current # bool
  # @modifies # arr of Shifts
end

class Periods
  include Ruby::Enum
  define :AM, 'am'
  define :PM, 'pm'
  define :DOUBLE, 'double'  
  # somewhat trivial question: instead of giving shifts and time_windows a @period
  # (with enums :AM, :PM, or :DOUBLE), i could instead give them an array of @periods
  # (with only enums :AM and :PM) and identify double shifts as having @periods.size > 1
  # as opposed to @period == :DOUBLE. not sure it matters in this instance, but is there 
  # a best practice i would observe by doing one or the other?
end

class Urgencies
  include Ruby::Enum
  define :WEEKLY, 'weekly'
  define :EXTRA, 'extra'
  define :EMERGENCY, 'emergency'
end

class Billing_Rates
  include Ruby::Enum
  define :NORMAL, 'normal'
  define :EXTRA, 'extra rider'
  define :EMERGENCY_EXTRA, 'emergency extra rider'
  define :LAST_MINUTE, 'last minute'
  define :FREE, 'free'
end

class Assignment
  belongs_to :shift # Shift
  belongs_to :rider # Rider
  belongs_to :time_window # TimeWindow
  
  @staffer # Staffer who made the assignment 
  @date # Date 
  @status # Assignment_Statuses::ENUM
  @current # bool
  @modifies # arr of Assignments that this assignment is an iteration of
            # ie: if the rider, status, or staffer handling the assignment changes, 
            # the assignment with "@current == true" will show the current status
            # and the @modifies attr of that Assignment will show the trail of prior Assignments it has taken the place of

end

class Assignment_Statuses
  include Ruby::Enum
  define :UNASSIGNED, 'unassigned'
  define :PROPOSED, 'proposed'
  define :DELEGATED, 'delegated'
  define :CONFIRMED, 'confirmed'
  define :REJECTED, 'rejected'
  define :CANCELLED_WITH_NOTICE, 'cancelled with notice'
  define :CANCELLED_LATE_NOTICE, 'cancelled late notice'
  define :NO_SHOW, 'no show'
end

class Assignment_Response
  @assignment # Assignment
  @rider # Rider
  @date # Date
  @response # Assignment_Responses::ENUM
end

class Assignment_Responses
  include Ruby::Enum
  define :CONFIRM, 'confirm'
  define :REJECT, 'reject'
  define :CANCEL, 'cancel'
  define :NO_SHOW, 'no show'
end

class AssignmentAction
  @assignment # Assignment
  @date # Date
  @staffer # Staffer
  @action # Assignment_Actions::ENUM
end

class Assignment_Actions < Assignment_Responses
  define :CREATE, 'create'
  define :PROPOSE, 'propose'
  define :DELEGATE, 'delegate'
end

class Request
  @shift # Shift
  @restaurant # Restaurant
  @staffer # Staffer
  @status # Request_Statuses::ENUM
end

class Request_Statuses
  include Ruby::Enum
  define :REQUESTED, 'requested'
  define :CANCELLED_WITH_NOTICE, 'cancelled with notice'
end

class Request_Actions
  include Ruby::Enum
  define :CREATE, 'create'
  define :CANCEL, 'cancel'
end

class Conflict
  @rider # Rider
  @start # Date
  @end # Date
  @time_windows # arr of Time_Windows
end

class Calendar
  @id # Google Calendar id
  @restaurant # Restaurant
end

class Event
  @id # Google Calendar Event id
  @calendar # Calendar
  @time_windows # arr of Time_Windows
end

class Week
  @start # Date
  @end # Date
  @time_windows # arr of Time_Windows
  has_and_belongs_to_many :invoices
  has_many :rider_schedules
  has_many :restaurant_schedules
  has_many :shifts, through :restaurant_schedules
end

class Time_Window
  @year # Date.year
  @month # Date.month
  @day # Date.mday
  @period # Periods.ENUM
  belongs_to :week
  has_many :assignments
  has_many :conflicts
  has_many :shifts
end

class Schedule
  belongs_to :week
  has_many :assignments
end



class Email
  @sender # Staffer
  @params # Email_Params
end

class Email_Params
  @to # str
  @subject # str
  @body # body
end

class Schedule_Email < Email
  @rider # Rider
  @shifts # arr of Shifts belonging to @rider
  @type # Email_Type
end

class Email_Type
  include Ruby::Enum
  define :WEEKLY, 'weekly'
  define :EXTRA_DELEGATION, 'extra delegation'
  define :EXTRA_CONFIRMATION, 'extra confirmation'
  define :EMERGENCY_DELEGATION, 'emergency delegation'
  define :EMERGENCY_CONFIRMATION, 'emergency confirmation'
end

class Invoice_Email < Email
  @restaurant # Restaurant
  @shifts # arr of Shifts belonging to @restaurant
end

class Invoice
  @restaurant # Restaurant
  @week # Week
  @date_issued # Date
  @shifts # arr of Shifts belonging to @restaurant during @week
  @fees # num
  @discount # num
  @revenue # num
  @tax # num
  @charge #num
  @balance # num
  @total_owed # num
  @paid_in_full? # bool
  @partial_payment_amount # num
end

class Payment
  @restaurant # Restaurant
  @amount_paid # num
  @payment_method # Payment_Methods::ENUM
  @check_num # num
  @date_paid # Date
  @invoices_paid # arr of Invoices
end

class Payment_Methods
  include Ruby::Enum
  define :CASH, 'cach'
  define :CHECK, 'check'
  define :CREDIT, 'credit'
  define :VENMO, 'Venmo'
  define :SQUARE_APP 'Square App'
end

class Balance
  @restaurant # Restaurant
  @amount # num
  @updated # date
  @current # bool
  @modifies # arr of Balances
end

class Edit
  @date # Date
  @user # User
  @obj_modified # str
  @old_state # obj 
  @new_state # obj
end
