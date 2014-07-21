# == Schema Information
#
# Table name: managers
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros

describe Manager do
  
  let(:manager) { FactoryGirl.create(:manager, :without_restaurant) }
  let(:associations) { [ :account, :contact] }
  subject { manager }

  describe "validation" do
    it { should be_valid }
  end

  it "should respond to all association references" do
    check_associations manager, associations
  end
end
