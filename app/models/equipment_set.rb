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

class EquipmentSet < ActiveRecord::Base
  belongs_to :equipable
end
