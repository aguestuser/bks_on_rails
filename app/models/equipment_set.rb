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
#  car            :boolean
#

class EquipmentSet < ActiveRecord::Base
  include Importable
  belongs_to :equipable

  validates :bike, :lock, :helmet, :rack, :bag, :heated_bag, :cell_phone, :smart_phone,
    inclusion: { in: [ true, false ] }
end



m = Manager.create!(account: Account.create!(password: 'foobar', password_confirmation: 'foobar'), contact: Contact.create!(name: 'nameo', email: 'notrecorded@example.com', phone: '212-666-6666', title: 'nice guy'))