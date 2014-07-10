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
      it { should respond_to(:user_info)}
      its(:email) { should eq staffer.user_info.email }
      its(:title) { should eq staffer.user_info.title }
      # describe "find_by_email" do
      #   let(:expected_id) { Staffer.find_by_email(staffer.user_info.email).id }
      #   it "should retrieve the correct staffer" do
      #     expect(staffer.id).to eq expected_id
      #   end
      # end
    end

  end
end


