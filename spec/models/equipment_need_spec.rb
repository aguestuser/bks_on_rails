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

require 'spec_helper'

describe EquipmentNeed do
  pending "add some examples to (or delete) #{__FILE__}"
end
