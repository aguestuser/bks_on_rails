# == Schema Information
#
# Table name: staffers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  contact_info_id :integer
#

require 'spec_helper'

describe Staffer do
  
  let(:staffer) { FactoryGirl.create(:staffer) }
  subject { staffer }

  describe "attributes" do
    it { should respond_to(:title) }
  end

  # describe "methods" do
  describe "find_by_email" do
    let(:expected_id) { Staffer.find_by_email(staffer.email).id }
    it "should retrieve the correct staffer" do
      expect(staffer.id).to eq expected_id
    end
  end

  describe "associations" do
    describe "contact info" do
      it { should respond_to(:contact_info)}
      its(:email) { should eq staffer.contact_info.email }
      its(:name) { should eq staffer.contact_info.name }
    end
  end
end
