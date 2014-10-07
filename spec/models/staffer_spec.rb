# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Staffer do
  
  let(:staffer) { FactoryGirl.build(:staffer) }
  let(:associations) { [ :account, :contact ] }
  subject { staffer }


  it { should be_valid }

  it "should respond to all association references" do
    check_associations staffer, associations
  end

  describe "class methods" do

    describe "Staffer.import" do
      let!(:old_count){ Staffer.count }
      before { Staffer.import }

      it "should create 4 new staffers with correct info" do
        expect(Staffer.count).to eq old_count + 4
        # expect(Assignment.last(3).map { |a| filter_uniq_attrs a.attributes } ).to eq imported_assignment_attrs
      end    
    end
  end
end


