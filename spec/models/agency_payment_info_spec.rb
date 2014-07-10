# == Schema Information
#
# Table name: agency_payment_infos
#
#  id              :integer          not null, primary key
#  method          :string(255)
#  pickup_required :boolean
#  restaurant_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'
include ValidationMacros

describe AgencyPaymentInfo do
  let(:api) { FactoryGirl.build(:agency_payment_info, :without_restaurant) }
  let(:attrs) { [:method, :pickup_required] }
  subject { api }

  describe "attributes" do

    it "should respond to all attributes" do
      check_attributes api, attrs
    end  
  end

  describe "validations" do
    
    it { should be_valid }

    it "shouldn't be valid without required attributes" do
      check_required_attributes api, attrs
    end

    describe "of enums" do
      describe "of method" do
        before { api.method = 'foobar' }
        it { should_not be_valid }
      end
    end
  end

  describe "associations" do
    it { should respond_to :restaurant_id }
  end
end
