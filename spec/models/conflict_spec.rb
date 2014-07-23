# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  date       :datetime
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Conflict do
  let(:conflict) { FactoryGirl.build(:conflict, :without_rider) }
  let(:attrs) { [ :rider_id, :date, :period ] }

  subject { conflict }

  it "should respond to all attributes" do
    check_attributes conflict, attrs
  end

  describe "validation" do
    
    it { should be_valid }
    it "should be invalid without required attribtues" do
      check_required_attributes conflict, attrs
    end
  end

  it "should respond to association messages" do
    check_associations conflict, [ :rider ]
  end
end
