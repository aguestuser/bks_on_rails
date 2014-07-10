# == Schema Information
#
# Table name: qualification_sets
#
#  id                :integer          not null, primary key
#  hiring_assessment :text
#  experience        :text
#  geography         :text
#  created_at        :datetime
#  updated_at        :datetime
#  rider_id          :integer
#

require 'spec_helper'
include ValidationMacros

describe QualificationSet do
  let(:q_set) { FactoryGirl.build(:qualification_set, :without_rider) }
  let(:attrs) { [:hiring_assessment, :experience, :geography ] }
  subject { q_set }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes q_set, attrs
    end
  end

  describe "validation" do
    it "shouldn't be valid without required attributes" do
      check_required_attributes q_set, attrs
    end
  end

  describe "associations" do
    it { should respond_to :rider }
  end
end
