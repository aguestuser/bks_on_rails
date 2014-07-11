# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Staffer do
  
  let(:staffer) { FactoryGirl.build(:staffer) }
  subject { staffer }

  describe "validation" do
    it { should be_valid }
  end

  describe "associations" do

    describe "with UserInfo model" do
      it { should respond_to(:account)}
    end

  end
end


