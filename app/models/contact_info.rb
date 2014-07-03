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

# include ContactInfoHelpers

class ContactInfo < ActiveRecord::Base
  include Boroughs, Neighborhoods
  #associations
  belongs_to :contactable, polymorphic: true

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

  #class methods
  def self.boroughs
    Boroughs.values
  end

  def self.neighborhoods
    Neighborhoods.values
  end

end
