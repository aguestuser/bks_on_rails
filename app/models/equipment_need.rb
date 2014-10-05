# == Schema Information
#
# Table name: equipment_needs
#
#  id            :integer          not null, primary key
#  bike_provided :boolean
#  rack_required :boolean
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class EquipmentNeed < ActiveRecord::Base
  include Importable
  belongs_to :restaurant

  validates :bike_provided, :rack_required, inclusion: { in: [ true, false ] }
end
