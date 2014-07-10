# == Schema Information
#
# Table name: rider_payment_infos
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  method        :string(255)
#  rate          :string(255)
#  shift_meal    :boolean
#  cash_out_tips :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros

describe RiderPaymentInfo do
  let(:rpi) { FactoryGirl.build(:rider_payment_info, :without_restaurant) }
    let(:attrs) { [:method, :rate, :shift_meal, :cash_out_tips] }
    subject { rpi }

    describe "attributes" do

      it "should respond to all attributes" do
        check_attributes rpi, attrs
      end  
    end

    describe "validations" do
      
      it { should be_valid }

      it "shouldn't be valid without required attributes" do
        check_required_attributes rpi, attrs
      end

      describe "of payment method" do
        before { rpi.method = 'foobar' }
        it { should_not be_valid } 
      end
    end

    describe "associations" do
      
      it { should respond_to :restaurant_id }
    end
end
