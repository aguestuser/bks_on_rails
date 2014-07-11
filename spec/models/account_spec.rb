# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

require 'spec_helper'
include ValidationMacros

describe Account do
  
  let(:account) { FactoryGirl.create(:account, :without_user) }
  let(:associations) { [:user, :contact] }
  subject { account }

  describe "attributes" do
  end

  describe "validation" do
    it { should be_valid }
  end

  describe "associations" do
    it "should respond to references to all associations" do
      check_associations account, associations
    end
  end
end
