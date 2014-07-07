# == Schema Information
#
# Table name: restaurants
#
#  id                    :integer          not null, primary key
#  active                :boolean
#  status                :string(255)
#  description           :text
#  agency_payment_method :string(255)
#  pickup_required       :boolean
#  created_at            :datetime
#  updated_at            :datetime
#

require 'spec_helper'
include ValidationMacros

describe Restaurant do
  let(:restaurant) { FactoryGirl.create(:restaurant) }
  subject { restaurant }

  describe "attributes" do
    let(:attributes) { [
      :active, :status, :description, :payment_method, :pickup_required, :created_at, :updated_at ] }
    it "should respond to all attributes" do
      check_attributes restaurant, attributes
    end
  end

  describe "associations" do
    it { should respond_to(:managers) }
    it { should respond_to(:contact_info) }
  end

  describe "validations" do
    let(:required_attribtues) { [ 
      :active, :status, :description, :payment_method ] }
    it "should be invalid when required fields are nil" do
      check_required_attributes restaurant, required_attribtues
    end
  end
end
