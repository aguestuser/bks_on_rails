class Location < ActiveRecord::Base
  belongs_to :locatable, polymorphic: :true

  classy_enum_attr :borough, allow_nil: true 
  classy_enum_attr :neighborhood, allow_nil: true  

  # VALID_STREET_ADDRESS = /\A((?!brooklyn|manhattan|queens|bronx|staten island|nyc|NY).)*\z/i
  validates :street_address, :borough, :neighborhood, 
    presence: true  
end
