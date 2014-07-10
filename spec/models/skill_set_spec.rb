# == Schema Information
#
# Table name: skill_sets
#
#  id            :integer          not null, primary key
#  rider_id      :integer
#  bike_repair   :boolean
#  fix_flats     :boolean
#  early_morning :boolean
#  pizza         :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros

describe SkillSet do
  let(:skill_set) { FactoryGirl.build(:skill_set, :without_rider) }
  let(:attrs) { [ :bike_repair, :fix_flats, :early_morning, :pizza ] }

  subject { skill_set }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes skill_set, attrs    
    end
  end

  describe "validations" do
    it { should be_valid }
    it "shouldn't be valid without required attributes" do
      check_required_attributes skill_set, attrs       
    end
  end

  describe "associations" do
    it { should respond_to :rider }   
  end 
end
