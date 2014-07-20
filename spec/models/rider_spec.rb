# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Rider do
  let(:rider) { FactoryGirl.build(:rider) }
  let(:attrs) { [:active] }
  let(:associations) { [ :assignments, :account, :equipment_set, :qualification_set, :rider_rating, :location ] }

  subject { rider }

  describe "attributes" do
    it { should respond_to :active }
  end

  describe "validations" do
    it { should be_valid }
    it "shouldn't be valid without required attributes" do
      check_required_attributes rider, attrs
    end
  end

  describe "associations" do
    it "should respond to references to all associated models" do
      check_associations rider, associations
    end
  end
end
