# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  start      :datetime
#  end        :datetime
#

require 'spec_helper'
include ValidationMacros

describe Conflict do
  let(:conflict) { FactoryGirl.build(:conflict, :without_rider) }
  let(:attrs) { [ :rider_id, :start, :end, :period ] }

  subject { conflict }

  it "should respond to all attributes" do
    check_attributes conflict, attrs
  end

  describe "validation" do
    
    it { should be_valid }
    it "should be invalid without required attribtues" do
      check_required_attributes conflict, attrs
    end

    describe "with end before start" do
      before do
        conflict.end = 5.years.ago
      end
      it { should_not be_valid }
    end
  end

  describe "after save" do
    before { conflict.save }
    its(:period){ should_not be nil }
  end

  it "should respond to association messages" do
    check_associations conflict, [ :rider ]
  end
end


