# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  address        :string(255)
#  borough        :string(255)
#  neighborhood   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Location < ActiveRecord::Base
  belongs_to :locatable, polymorphic: :true

  classy_enum_attr :borough, allow_nil: true 
  classy_enum_attr :neighborhood, allow_nil: true  

  # VALID_STREET_ADDRESS = /\A((?!brooklyn|manhattan|queens|bronx|staten island|nyc|NY).)*\z/i
  validates :street_address, :borough, :neighborhood, 
    presence: true  
end
