# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  address        :string(255)
#  borough        :string(255)
#  neighborhood   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'
include ValidationMacros

describe Location do
  
  let(:location) { FactoryGirl.build(:location, :without_locatable) }
  let(:attrs) { [ :address, :borough, :neighborhood ] }
  subject { location }

  describe "attribtues" do
    it "should respond to all attribtues" do
      check_attributes location, attrs
    end
  end

  describe "validation" do

    it { should be_valid }

    describe "of required attributes" do
      it "should be invalid without required attributes" do
        check_required_attributes location, attrs
      end      
    end

    describe "of borough" do
      
      describe "with incorrect value" do
        before { location.borough = 'long island' }
        it { should_not be_valid }
      end
    end

    describe "of neighborhood" do
      
      describe "with incorrect value" do
        before { location.neighborhood = 'hoboken' }
        it { should_not be_valid }
      end
    end      
  end
end
