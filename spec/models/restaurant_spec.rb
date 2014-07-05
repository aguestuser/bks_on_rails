# == Schema Information
#
# Table name: restaurants
#
#  id              :integer          not null, primary key
#  active          :boolean
#  status          :string(255)
#  description     :text
#  payment_method  :string(255)
#  pickup_required :boolean
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Restaurant do
  let(:restaurant) { FactoryGirl.create(:restaurant) }
  subject { restaurant }

  describe "attributes" do
    it { should respond_to(:active) }
    it { should respond_to(:status) }
    it { should respond_to(:description) }
    it { should respond_to(:payment_method) }
    it { should respond_to(:pickup_required) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe "associations" do
    it { should respond_to(:managers) }
    it { should respond_to(:contact_info) }
  end

  describe "validations" do
    describe "when active is nil" do
      before { restaurant.active = nil }
      it { should_not be_valid }
    end

    describe "when status is nil" do
      before { restaurant.status = nil }
      it { should_not be_valid }
    end

    describe "when description is nil" do
      before { restaurant.description = nil }
      it { should_not be_valid }
    end

    describe "payment method is nil" do
      before { restaurant.payment_method = nil }
      it { should_not be_valid }
    end

    describe "pickup required is nil" do
      before { restaurant.payment_method = nil }
      it { should_not be_valid }
    end
    
  end
end
