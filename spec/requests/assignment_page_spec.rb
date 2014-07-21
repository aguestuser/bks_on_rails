require 'spec_helper'
include CustomMatchers
include RequestSpecMacros
include AssignmentRequestMacros

describe "Assignment Requests" do
  let(:staffer) { FactoryGirl.create(:staffer) }
  let(:rider) { FactoryGirl.create(:rider) }
  # let(:other_rider) { FactoryGirl.create(:rider) }

  let(:restaurant) { FactoryGirl.create(:restaurant) }
  # let(:other_restaurant) { FactoryGirl.create(:restaurant) }

  let!(:shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }
  let(:other_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }

  let(:assignment) { Assignment.new( rider_id: rider.id, shift_id: shift.id) }
  let(:other_assignment) { Assignment.new( rider_id: rider.id, shift_id: other_shift.id) }

  let(:assignment_start) { assignment.shift.start.strftime("%m/%d | %I:%M%p") }
  let(:assignment_end) { assignment.shift.end.strftime("%I:%M%p") }

  before { mock_sign_in staffer }

  subject { page }

  describe "Assignments#show" do
    
    before do
      assignment.save
      visit shift_assignment_path(shift, assignment)
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

    before { assignment.save }

    describe "from root path" do

      before { visit shifts_path }

      describe "page contents" do

        it { should have_content('Restaurant') } 
        it { should have_link(assignment.shift.restaurant.mini_contact.name) }
        it { should have_content('Start') }
        it { should have_content(assignment_start) }
        it { should have_content('Assigned to') }
        it { should have_content(assignment.rider.account.contact.name) }
        it { should have_content('Status') }
        it { should have_content(assignment.status.text) }
        it { should have_link('Edit Assignment') }
        it { should have_link('Assignment Details') }
        it { should have_link('Assign Shift') }
        it { should have_link('Create shift') }
        
        describe "with unassigned shift" do
          it { should have_content('--') }
          it { should have_link('Assign Shift') }
        end
      end

      describe "without unassigned shift" do
        
        before do
          assignment.save
          other_assignment.save
          visit restaurant_shifts_path(restaurant)
        end

        it { should_not have_content('--') }
        it { should_not have_link('Assign Shift') }
      end
    end

    describe "from restaurant path" do
      
      before { visit restaurant_shifts_path(restaurant) }

      it { should_not have_link(restaurant.mini_contact.name) }
      it { should have_content('Assigned to')}
      it { should have_link('Create shift') }
      it { should have_link('See all shifts') }
    end

    describe "from rider path" do
      
      before { visit rider_shifts_path(rider) }

      it { should have_content('Restaurant') }
      it { should have_content(restaurant.mini_contact.name) }
      it { should_not have_content('Assigned to')}
      it { should_not have_content('--') }
      it { should_not have_link('Create new shift') }      
      it { should have_link('See all shifts') }
    end
  end


  describe "Assignments#new" do
    
    before do
      rider
      restaurant
    end 

    let(:submit) { 'Assign shift' }
    let!(:old_counts) { count_models [ Assignment ] }

    describe "from shifts path" do
      before { visit new_shift_assignment_path(shift) }

      describe "page contents" do
        check_assignment_form_contents :new
      end

      describe "form submission" do

        describe "with invalid input" do
          before { click_button submit }

          it { should have_an_error_message }
        end

        describe "with valid input" do
          before { make_valid_assignment_submission }

          let(:new_counts) { count_models [ Assignment ] }
        
          it "should create a new Assignment" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_success_message("Shift assigned to #{rider.name}") }
          it { should have_h1('Shifts') }
        end
      end
    end

    describe "from restaurant path" do
      before { visit new_restaurant_shift_assignment_path(restaurant, shift) }

      describe "page contents" do
        check_assignment_form_contents :new, :restaurant
      end

      describe "form submission" do
        
        describe "with invalid input" do
          before { click_button submit }

          it { should have_an_error_message }
          it { should have_h1("Assign Shift") }
        end

        describe "with valid input" do
          before { make_valid_assignment_submission :restaurant }

          let(:new_counts) { count_models [ Assignment ] }

          it "should create a new Assignment" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_success_message("Shift assigned to #{rider.name}") }
          it { should have_h1("Shifts for #{restaurant.mini_contact.name}") }         
        end
      end
    end

    describe "from rider path" do
      before { visit new_rider_shift_assignment_path(rider, shift) }
      
      it { should have_an_error_message }
      it { should have_h1("Assignments for #{rider.name}") }
    end
  end

  describe "Assignments#edit" do
    before { assignment.save }
    
    let(:submit) { 'Save changes' }

    describe "from shifts path" do
      before { visit edit_shift_assignment_path(shift, assignment) }

      describe "page contents" do
        check_assignment_form_contents :edit
      end

      describe "with invalid input" do
        before  { make_invalid_assignment_submission }

        it { should have_an_error_message }
        it { should have_h1('Edit Shift Assignment') }
      end

      describe "with valid input" do
        before { make_valid_assignment_edit }

        describe "updating assignment attributes" do
          subject { assignment.reload }

          its(:rider) { should eq Rider.first }
          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider }          
        end

        describe "success redirect" do
          subject { page }
          
          it { should have_success_message("Assignment updated (Rider: #{Rider.first.name}, Status: Cancelled (Rider))") }
          it { should have_h1("Shifts") } 
        end
      end
    end

    describe "from restaurant path" do
      before { visit edit_restaurant_shift_assignment_path(restaurant, shift, assignment) }

      describe "page contents" do
        check_assignment_form_contents :edit, :restaurant
      end

      describe "with invalid input" do
        before { make_invalid_assignment_submission :restaurant }

        it { should have_an_error_message }
        it { should have_h1('Edit Shift Assignment') }
      end

      describe "with valid input" do
        before { make_valid_assignment_edit }

        describe "updating assignment attributes" do
          subject { assignment.reload }

          its(:rider) { should eq Rider.first }
          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider }
        end

        describe "success redirect" do
          subject { page }

          it { should have_success_message("Assignment updated (Rider: #{Rider.first.name}, Status: Cancelled (Rider))") }
          it { should have_h1("Shifts for #{restaurant.name}") } 
        end
      end
    end

    describe "from riders path" do
      before { visit edit_rider_shift_assignment_path(rider, shift, assignment) }      

      describe "page contents" do
        check_assignment_form_contents :edit, :rider        
      end

      describe "with valid input" do
        before { make_valid_assignment_edit :rider }

        describe "updating assignment attributes" do
          subject { assignment.reload }

          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider } 
        end

        describe "success redirect" do
          subject { page }

          it { should have_success_message("Assignment updated (Rider: #{rider.name}, Status: Cancelled (Rider))") }
          it { should have_h1("Assignments for #{rider.name}") }
        end
      end
    end
  end
end