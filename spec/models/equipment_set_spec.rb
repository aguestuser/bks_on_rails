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
include ValidationMacros

describe EquipmentSet do
  let(:equip) { FactoryGirl.build(:equipment_set, :without_equipable) }
  let(:attrs) { [ :bike, :lock, :helmet, :rack, :bag, :heated_bag, :cell_phone, :smart_phone] }
  subject { equip }

  describe "attrs" do
    it "should respond to all attributes" do
      check_attributes equip, attrs
    end
  end

  describe "validation" do
    it { should be_valid }
    
    it "shouldn't be valid without required attributes" do
      check_required_attributes equip, attrs
    end
  end

  describe "associations" do
    it { should respond_to :equipable_id }
  end
end
