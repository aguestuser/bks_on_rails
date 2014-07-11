# == Schema Information
#
# Table name: restaurants
#
#  id         :integer          not null, primary key
#  active     :boolean
#  status     :string(255)
#  brief      :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Restaurant do
  let(:restaurant) { FactoryGirl.build(:restaurant) }
  let(:attrs) { [ :active, :status, :brief ] }
  subject { restaurant }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes restaurant, attrs
    end
  end

  describe "validations" do
    it { should be_valid }
    let(:req_attrs) { [ :status, :brief ] }
    let(:enums){ [:status] }

    it "should be invalid when required fields are nil" do
      check_required_attributes restaurant, req_attrs
    end
    it "should be invalid when enum attrs don't correspond to enum values" do
      check_enums restaurant, enums
    end
  end

  describe "associations" do

    describe "with models it has" do
      it { should respond_to(:managers) }
      it { should respond_to(:short_contact_info) }
      it { should respond_to(:agency_payment_info) }
      it { should respond_to(:rider_payment_info) }
      it { should respond_to(:work_specification) }
      it { should respond_to(:location) }
      it { should respond_to(:equipment_set) }      
    end

  end


end
