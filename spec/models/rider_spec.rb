# == Schema Information
#
# Table name: riders
#
#  id         :integer          not null, primary key
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Rider do
  let(:rider) { FactoryGirl.build(:rider) }
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let(:attrs) { [ :active ] }
  let(:associations) { [ :account, :contact, :equipment_set, :qualification_set, :rider_rating, :location, :assignments, :shifts ] }

  subject { rider }

  describe "attributes" do
    it { should respond_to :active }
  end

  describe "validations" do
    it { should be_valid }
    it "shouldn't be valid without required attributes" do
      check_required_attributes rider, attrs
    end
  end

  describe "associations" do
    it "should respond to references to all associated models" do
      check_associations rider, associations
    end
  end

  describe "methods" do
    before { rider.save }
    let(:other_rider) { FactoryGirl.create(:rider) }
    # create 2 shifts on 1/1/14
    let(:shifts) do
      2.times.map do |n| 
        Shift.create!(
          restaurant_id: 1,
          start: DateTime.new(2014,1,n+1,11),
          :end => DateTime.new(2014,1,n+1,17),
          billing_rate: :normal,
          urgency: :weekly
        )
      end
    end
    let(:conflicts) do
      2.times.map do |n|
        Conflict.create!(
          rider_id: rider.id,
          start: DateTime.new(2014,1,n+1,17),
          :end => DateTime.new(2014,1,n+1,23),          
        )
      end
    end
    describe "shifts_on(date)" do
      before do 
        shifts.each { |shift| shift.assign_to rider }
      end
      it "should retrieve correct shifts" do
        expect( rider.shifts_on(Date.new(2014,1,1)).include? shifts[0] ).to eq true        
        expect( rider.shifts_on(Date.new(2014,1,1)).include? shifts[1] ).to eq false
        expect( rider.shifts_on(Date.new(2014,1,2)).include? shifts[0] ).to eq false        
        expect( rider.shifts_on(Date.new(2014,1,2)).include? shifts[1] ).to eq true
      end
      it "should retrieve empty array for date with no assignments" do
        expect( rider.shifts_on(Date.new(2014,2,1)) ).to eq []
      end
      it "should retrieve empty array for rider with no assignments on any date" do
        expect( other_rider.shifts_on(Date.new(2014,1,1)) ).to eq []
      end
    end

    describe "conflicts_on(date)" do
      it "should retrieve correct conflicts" do
        expect( rider.conflicts_on(Date.new(2014,1,1)).include? conflicts[0] ).to eq true        
        expect( rider.conflicts_on(Date.new(2014,1,1)).include? conflicts[1] ).to eq false
        expect( rider.conflicts_on(Date.new(2014,1,2)).include? conflicts[0] ).to eq false        
        expect( rider.conflicts_on(Date.new(2014,1,2)).include? conflicts[1] ).to eq true        
      end
      it "should retrieve empty array for date with no conflicts" do
        expect( rider.conflicts_on(Date.new(2014,2,1)) ).to eq []
      end
      it "should retrieve empty array for rider with no conflicts on any date" do
        expect( other_rider.conflicts_on(Date.new(2014,1,1)) ).to eq []
      end      
    end
  end
end
