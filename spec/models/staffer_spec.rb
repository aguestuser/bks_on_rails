# == Schema Information
#
# Table name: staffers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  title           :string(255)
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
  # end

  describe "associations" do
    describe "contact info" do
      it { should respond_to(:contact_info)}
      its(:email) { should eq staffer.contact_info.email }
      its(:name) { should eq staffer.contact_info.name }
    end
  end
end
