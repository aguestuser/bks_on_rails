# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Rider < ActiveRecord::Base
  include User, Equipable # app/models/concerns/

  has_one :qualification_set
    accepts_nested_attributes_for :qualification_set
  has_one  :skill_set
    accepts_nested_attributes_for :skill_set
  has_one :rider_rating
    accepts_nested_attributes_for :rider_rating

  validates :active, 
    presence: true,
    inclusion: { in: [ true, false ] }
end
