# == Schema Information
#
# Table name: shifts
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  start         :datetime
#  end           :datetime
#  period        :string(255)
#  urgency       :string(255)
#  billing_rate  :string(255)
#  notes         :text
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros, IoMacros

describe Shift do
  let(:shift) { FactoryGirl.build(:shift, :without_restaurant) }
  let(:attrs) { [ :start, :end, :period, :urgency, :billing_rate, :notes ] }
  let(:associations) { [ :restaurant, :assignment ] }

  subject { shift }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes shift, attrs
    end
  end

  describe "validation" do
    let(:req_attrs) { attrs[0..4] }
    let(:enums) { [ :billing_rate, :urgency ] }  
    it "shouldn't be valid without required attributes" do
      check_required_attributes shift, req_attrs
    end
    it "shouldn't be valid when enum attrs don't correspond to enum values" do
      check_enums shift, enums
    end
    describe "of end date after start date" do
      before do
        shift.start = 1.hour.ago
        shift.end = 3.hours.ago
      end
      it { should_not be_valid }
    end
  end

  it "should respond to associated models" do
    check_associations shift, associations
  end

  describe "methods" do
    let(:rider){ FactoryGirl.create(:rider) }
    
    describe "assign_to(rider)" do
      before do
        shift.save
        shift.assign_to rider
      end
      specify { expect(shift.assignment.rider).to eq rider }
    end
  end

  describe "methods" do

    # let(:rider) { FactoryGirl.create(:rider) }
    let!(:shift) { FactoryGirl.create(:shift, :without_restaurant) }
    # let(:new_assignment) do 
    #   Assignment.new(rider_id: rider.id, shift_id: shift.id )
    # end

    # let(:test_shifts){ same_time_shift, early_overlap_shift, late_overlap_shift, just_before_shift, just_after_shift, day_before_shift, day_after_shift ] }

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
        
        expect( shift.conflicts_with?( same_time_conflict ) ).to eq true 
        expect( shift.conflicts_with?( early_overlap_conflict ) ).to eq true  
        expect( shift.conflicts_with?( late_overlap_conflict ) ).to eq true                
        expect( shift.conflicts_with?( just_before_conflict ) ).to eq false
        expect( shift.conflicts_with?( just_after_conflict ) ).to eq false 
        expect( shift.conflicts_with?( day_before_conflict ) ).to eq false 
        expect( shift.conflicts_with?( day_after_conflict ) ).to eq false 
      end
    end

    describe "double_books_with?" do
      
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

      it "should correctly identify double bookings" do
        expect( shift.double_books_with?( same_time_shift ) ).to eq true
        expect( shift.double_books_with?( early_overlap_shift ) ).to eq true
        expect( shift.double_books_with?( late_overlap_shift ) ).to eq true
        expect( shift.double_books_with?( just_before_shift ) ).to eq false
        expect( shift.double_books_with?( just_after_shift ) ).to eq false
        expect( shift.double_books_with?( day_before_shift ) ).to eq false
        expect( shift.double_books_with?( day_after_shift ) ).to eq false        
      end
    end
  end

  describe "class methods" do

    describe "Shift.import" do
      load_imported_assignment_attrs
      let!(:old_count){ Shift.count }
      before { Shift.import }

      it "should create 3 new shifts with correct assignments" do
        expect(Shift.count).to eq old_count + 3
        expect(Assignment.last(3).map { |a| filter_uniq_attrs a.attributes } ).to eq imported_assignment_attrs
      end    
    end
  end
end
