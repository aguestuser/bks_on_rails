# == Schema Information
#
# Table name: equipment_sets
#
#  id             :integer          not null, primary key
#  equipable_id   :integer
#  equipable_type :string(255)
#  bike           :boolean
#  lock           :boolean
#  helmet         :boolean
#  rack           :boolean
#  bag            :boolean
#  heated_bag     :boolean
#  cell_phone     :boolean
#  smart_phone    :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe EquipmentSet do
  pending "add some examples to (or delete) #{__FILE__}"
end
