# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

require 'spec_helper'
include ValidationMacros

describe UserInfo do
  
  let(:user_info) { FactoryGirl.create(:user_info, :without_user) }
  let(:associations) { [:user, :contact_info] }
  subject { user_info }

  describe "attributes" do
  end

  describe "validation" do
    it { should be_valid }
  end

  describe "associations" do
    it "should respond to references to all associations" do
      check_associations user_info, associations
    end
  end
end
