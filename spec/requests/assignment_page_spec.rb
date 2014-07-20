require 'spec_helper'
include CustomMatchers
include RequestSpecMacros
# include AssignmentRequestMacros

describe "Assignment Requests" do
  let(:staffer) { FactoryGirl.create(:staffer) }
  let!(:rider) { FactoryGirl.create(:rider) }
  let(:other_rider) { FactoryGirl.create(:rider) }

  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let(:other_restaurant) { FactoryGirl.create(:restaurant) }

  let!(:shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }
  let(:second_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }
  let(:other_shift) { FactoryGirl.create(:shfit, :with_restaurant, restaurant: other_restaurant) }

  let(:assignment) { Assignment.new( rider_id: rider.id, shift_id: shift.id) }
  let(:second_assignment) { Assignment.new(rider_id: rider_id, shift_id: second_shift.id ) }
  let(:other_assignment) { Assignment.new( rider_id: other_rider.id, shift_id: other_shift.id) }

  before { mock_sign_in staffer }

  subject { page }

  describe "Assignments#show" do
    
    before do
      assignment.save
      visit assignment_path(assignment)
    end

    describe "page contents" do
      it { should have_h3('Assignment Details') }
      it { should have_content('Shift:') }
      it { should have_content('Assigned to:') }
      it { should have_content('Status:') }
      it { should have_h3('Assignment History') }
    end
  end

  describe "Assignments#index" do
    


    describe "from restaurant path" do
      
      before do
        assignment.save
        visit restaurant_shifts_path(restaurant)
      end

      describe "page contents" do
        it { should have_content('Assigned to') }
        it { should have_content('Status') }
        it { should have_link('Edit Assignment') }
        it { should have_link('Assignment Details') }
        it { should have_link('Assign Shift') }
      end
    end
  end
    



end