# == Schema Information
#
# Table name: shifts
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  start         :datetime
#  end           :datetime
#  period        :string(255)
#  urgency       :string(255)
#  billing_rate  :string(255)
#  notes         :text
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros

describe Shift do
  let(:shift) { FactoryGirl.build(:shift, :without_restaurant) }
    let(:attrs) { [:start, :end, :period, :urgency, :billing_rate, :notes] }
  
  subject { shift }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes shift, attrs
    end
  end

  describe "validation" do
    let(:req_attrs) { attrs[0..4] }
    let(:enums) { [ :period, :billing_rate, :urgency ] }  
    it "shouldn't be valid without required attributes" do
      check_required_attributes shift, req_attrs
    end
    it "shouldn't be valid when enum attrs don't correspond to enum values" do
      check_enums shift, enums
    end
    describe "of end date after start date" do
      before do
        shift.start = 1.hour.ago
        shift.end = 3.hours.ago
      end
      it { should_not be_valid }
    end
  end

  describe "associations" do
    it { should respond_to :restaurant_id }
  end

end
