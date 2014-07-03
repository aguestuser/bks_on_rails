# == Schema Information
#
# Table name: contact_infos
#
#  id             :integer          not null, primary key
#  phone          :string(255)
#  email          :string(255)
#  street_address :string(255)
#  borough        :string(255)
#  neighborhood   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'ruby_enum.rb'

class Boroughs 
  include Ruby::Enum
  define :MANHATTAN, 'Manhattan'
  define :BROOKLYN, 'Brooklyn'
  define :QUEENS, 'Queens'
  define :BRONX, 'Bronx'
  define :STATEN_ISLAND, 'Staten Island'
end

class Neighborhoods # note: will need to update this set of enums as we add more neighborhoods
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



class ContactInfo < ActiveRecord::Base
  #before filters
  before_save { street_address.strip! }
  before_save { email.downcase! }

  #validations
  VALID_STREET_ADDRESS = /\A((?!brooklyn|manhattan|queens|bronx|staten island|nyc|NY).)*\z/i
  validates :street_address, presence: true, 
                      format: { with: VALID_STREET_ADDRESS }
  validates :borough, presence: true, 
                      inclusion: { in: Boroughs.values }
  validates :neighborhood,  presence: true, 
                            inclusion: { in: Neighborhoods.values }
  VALID_PHONE = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates :phone, presence: true, 
                    format: { with: VALID_PHONE }
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL },
                    uniqueness: { case_sensitive: false } 

end
