# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  rider_id   :integer
#  status     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
include ValidationMacros

describe Assignment do
  let(:assignment) { FactoryGirl.build(:assignment) }
  let(:attrs) { [ :status, :shift_id, :rider_id ] }
  let(:required_attrs) { attrs[1..2] }
  let(:associations) { [ :shift, :rider ] }
  let(:enums) { [ :status ] }

  subject { assignment }


  it "should respond to all attributes" do
    check_attributes assignment, attrs
  end


  describe "validations" do
    it { should be_valid }

    it "should be invalid when required fields are nil" do
      check_required_attributes assignment, required_attrs
    end

    it "should be invalid when enum attrs don't corresond to enum values" do
      check_enums assignment, enums
    end
  end

  it "should respond to all associations" do
    check_associations assignment, associations
  end

  describe "methods" do

    let(:rider) { FactoryGirl.create(:rider) }
    let!(:shift) { FactoryGirl.create(:shift, :without_restaurant) }
    let(:new_assignment) do 
      Assignment.new(rider_id: rider.id, shift_id: shift.id )
    end

    let(:same_time_shift) do
      FactoryGirl.create(:shift, :without_restaurant, start: shift.start, :end => shift.end)
    end
    let(:early_overlap_shift) do
      FactoryGirl.create(:shift, :without_restaurant, start: shift.start - 3.hours, :end => shift.end - 3.hours)
    end
    let(:late_overlap_shift) do
      FactoryGirl.create(:shift, :without_restaurant, start: shift.start + 3.hours, :end => shift.end + 3.hours)
    end
    let(:just_before_shift) do
      FactoryGirl.create( :shift, :without_restaurant, start: shift.start - 5.hours, :end => shift.start )     
    end
    let(:just_after_shift) do
      FactoryGirl.create( :shift, :without_restaurant, start: shift.end, :end => shift.end + 5.hours )       
    end
    let(:day_before_shift) do
      FactoryGirl.create( :shift, :without_restaurant, start: shift.start - 1.day, :end => shift.end - 1.day )     
    end
    let(:day_after_shift) do
      FactoryGirl.create( :shift, :without_restaurant, start: shift.start + 1.day, :end => shift.end + 1.day )       
    end

    let(:test_shifts){ [ same_time_shift, early_overlap_shift, late_overlap_shift, just_before_shift, just_after_shift, day_before_shift, day_after_shift ] }

    describe "conflicts_with?(conflicts)" do

      let(:same_time_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start, :end => shift.end )
      end
      let(:early_overlap_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start - 3.hours, :end => shift.end - 3.hours )
      end     
      let(:late_overlap_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start + 3.hours, :end => shift.end + 3.hours )
      end     
      let(:just_before_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start - 5.hours, :end => shift.start )
      end
      let(:just_after_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.end, :end => shift.end + 5.hours )
      end
      let(:day_before_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start - 1.day, :end => shift.end - 1.day )
      end      
      let(:day_after_conflict) do
        FactoryGirl.create( :conflict, :without_rider, start: shift.start + 1.day, :end => shift.end + 1.day )
      end

      it "should correctly identify conflicts" do
        expect( new_assignment.conflicts_with?( [ same_time_conflict ] ) ).to eq true 
        expect( new_assignment.conflicts_with?( [ early_overlap_conflict ] ) ).to eq true  
        expect( new_assignment.conflicts_with?( [ late_overlap_conflict ] ) ).to eq true                
        expect( new_assignment.conflicts_with?( [ just_before_conflict ] ) ).to eq false
        expect( new_assignment.conflicts_with?( [ just_after_conflict ] ) ).to eq false 
        expect( new_assignment.conflicts_with?( [ day_before_conflict ] ) ).to eq false 
        expect( new_assignment.conflicts_with?( [ day_after_conflict ] ) ).to eq false 
      end
    end

    describe "double_books_with?" do
      
      before { test_shifts.each { |shift| shift.assign_to rider } }

      it "should correctly identify double bookings" do
        expect( new_assignment.double_books_with?( [ same_time_shift.assignment ] ) ).to eq true
        expect( new_assignment.double_books_with?( [ early_overlap_shift.assignment ] ) ).to eq true
        expect( new_assignment.double_books_with?( [ late_overlap_shift.assignment ] ) ).to eq true
        expect( new_assignment.double_books_with?( [ just_before_shift.assignment ] ) ).to eq false
        expect( new_assignment.double_books_with?( [ just_after_shift.assignment ] ) ).to eq false
        expect( new_assignment.double_books_with?( [ day_before_shift.assignment ] ) ).to eq false
        expect( new_assignment.double_books_with?( [ day_after_shift.assignment ] ) ).to eq false        
      end
    end
  end
end
