# == Schema Information
#
# Table name: work_arrangements
#
#  id                     :integer          not null, primary key
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  pay_rate               :string(255)
#  shift_meal             :boolean
#  cash_out_tips          :boolean
#  rider_on_premises      :boolean
#  extra_work             :boolean
#  extra_work_description :string(255)
#  bike                   :boolean
#  lock                   :boolean
#  rack                   :boolean
#  bag                    :boolean
#  heated_bag             :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  restaurant_id          :integer
#  rider_payment_method   :string(255)
#

require 'spec_helper'
include ValidationMacros

describe WorkArrangement do
  let(:work_arrangement) { FactoryGirl.create(:work_arrangement) }
  subject { work_arrangement }

  describe "attributes" do
    let(:attributes){ [ 
      :zone, :daytime_volume, :evening_volume, :rider_payment_method,
      :pay_rate, :shift_meal, :cash_out_tips, :rider_on_premises, :extra_work, :extra_work_description,
      :bike, :lock, :rack, :bag, :heated_bag ] }
    it "should respond to all attributes" do
      check_attributes work_arrangement, attributes
    end
  end 

  describe "associations" do
    it { should respond_to(:restaurant) }
  end

  describe "validations" do
    let(:required_attributes) { [
      :zone, :daytime_volume, :evening_volume, :rider_payment_method ] }
    it "should be invalid when required fields are nil" do
      check_required_attributes work_arrangement, required_attributes  
    end
  end
end

def check_attributes(model, attributes)
  attributes.each do |attr|
    expect(model).to respond_to attr
  end
end
