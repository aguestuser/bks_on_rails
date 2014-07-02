class EmailAddress < ActiveRecord::Base

  #associations

  #before filters
  before_save { value.downcase! }

  #validations
  validates :primary, presence: true
  VALID_ADDRESS = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :value, presence: true,
                    format: { with: VALID_ADDRESS },
                    uniqueness: { case_sensitive: false } 
end
