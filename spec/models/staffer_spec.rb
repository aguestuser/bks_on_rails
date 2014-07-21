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
end


