# == Schema Information
#
# Table name: assignments
#
#  id                      :integer          not null, primary key
#  shift_id                :integer
#  rider_id                :integer
#  status                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  override_conflict       :boolean
#  override_double_booking :boolean
#

require 'spec_helper'
include ValidationMacros

describe Assignment do
  let(:assignment) { FactoryGirl.build(:assignment) }
  let(:attrs) { [ :shift_id, :status, :rider_id ] }
  let(:associations) { [ :shift, :rider ] }
  let(:enums) { [ :status ] }

  subject { assignment }


  it "should respond to all attributes" do
    check_attributes assignment, attrs
  end


  describe "validations" do
    it { should be_valid }

    it "should be invalid when enum attrs don't corresond to enum values" do
      check_enums assignment, enums
    end

    describe "emergency shift delegation" do
      before do 
        assignment.shift.update(urgency: :emergency)
        assignment.update(status: :delegated)
      end
      it { should_not be_valid }
    end
  end

  it "should respond to all associations" do
    check_associations assignment, associations
  end
end
