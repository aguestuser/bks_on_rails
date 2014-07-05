# == Schema Information
#
# Table name: contact_infos
#
#  id               :integer          not null, primary key
#  phone            :string(255)
#  email            :string(255)
#  street_address   :string(255)
#  borough          :string(255)
#  neighborhood     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  contactable_id   :integer
#  contactable_type :string(255)
#  name             :string(255)
#  title            :string(255)
#

class ContactInfo < ActiveRecord::Base
  include Boroughs, Neighborhoods
  #associations
  belongs_to :contactable, polymorphic: true

  #before filters
  before_save { street_address.strip! if street_address }
  before_save { email.downcase! if email }


  #validations

  validates :name, presence: true
  VALID_PHONE = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates :phone, presence: true, 
              format: { with: VALID_PHONE }
  VALID_STREET_ADDRESS = /\A((?!brooklyn|manhattan|queens|bronx|staten island|nyc|NY).)*\z/i
  validates :street_address,  
              presence: true, 
              format: { with: VALID_STREET_ADDRESS },
              if: "contactable_is?('Restaurant')"
  validates :borough, 
              presence: true, 
              inclusion: { in: Boroughs.values },
              if: "contactable_is?('Restaurant') || contactable_is?('Rider')"
  validates :neighborhood,  
              presence: true, 
              inclusion: { in: Neighborhoods.values },
              if: "contactable_is?('Restaurant')"
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, 
              presence: true,
              format: { with: VALID_EMAIL },
              uniqueness: { case_sensitive: false }, 
              unless: "contactable_is?('Restaurant')"

  #class methods
  def self.boroughs
    Boroughs.values
  end

  def self.neighborhoods
    Neighborhoods.values
  end

  #public methods
  def contactable_type
    self.contactable.class.name
  end

  def contactable_is?(contactable_type)
    self.contactable.class.name == contactable_type
  end

end
