require 'spec_helper'
include CustomMatchers
include RequestSpecMacros
include AssignmentRequestMacros

describe "Assignment Requests" do
  let(:staffer) { FactoryGirl.create(:staffer) }
  let(:rider) { FactoryGirl.create(:rider) }
  let(:other_rider) { FactoryGirl.create(:rider) }

  let(:restaurant) { FactoryGirl.create(:restaurant) }
  let(:other_restaurant) { FactoryGirl.create(:restaurant) }

  let(:start){ DateTime.new(2014,1,1,11) }
  let(:_end){ DateTime.new(2014,1,1,17) }

  let!(:shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start, :end => _end) }
  let!(:next_day_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start + 1.day, :end => _end + 1.day) }
  let(:same_time_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: other_restaurant, start: start, :end => _end) }
  let(:conflict){ FactoryGirl.create(:conflict, rider: rider, start: start + 1.day, :end => _end + 1.day) }

  let(:assignment) { Assignment.new( rider_id: rider.id, shift_id: shift.id) }
  let(:other_assignment) { Assignment.new( rider_id: rider.id, shift_id: next_day_shift.id) }

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

  describe "Assignments in Shifts#index" do

    before { assignment.save }

    describe "from root path" do

      before { visit shifts_path }

      describe "page contents" do

        it { should have_content('Restaurant') } 
        it { should have_link(assignment.shift.restaurant.mini_contact.name) }
        it { should have_content('Start') }
        it { should have_content(assignment_start) }
        it { should have_content('Assigned to') }
        it { should have_content(assignment.rider.contact.name) }
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

      it { should_not have_row_header('Restaurant') }
      it { should have_row_header('Start')}
      it { should have_row_header('End')}
      it { should have_row_header('Assigned to')}
      it { should have_row_header('Status')}
      
      it { should have_link('Create shift') }
      it { should have_link('All shifts') }
    end

    describe "from rider path" do
      
      before { visit rider_shifts_path(rider) }

      it { should have_row_header('Restaurant') }
      it { should have_content(restaurant.mini_contact.name) }
      it { should_not have_content('Assigned to')}
      it { should_not have_content('--') }
      it { should_not have_link('Create new shift') }      
      it { should have_link('All shifts') }
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

        describe "making new assignment to rider with conflict" do
          before do
            conflict
            visit new_shift_assignment_path(next_day_shift)
            make_valid_assignment_submission
          end


          describe "override page contents" do
            it { should have_h1('Conflict Alert') }
            it { should have_content("You tried to assign the following shift:") }
            it { should have_content( next_day_shift.start.strftime( "%m/%d | %I:%M%p" ) ) }  
            it { should have_content("to #{rider.contact.name}, who has the following conflict(s):") }
            it { should have_content(conflict.start.strftime("%m/%d | %I:%M%p")) }
            it { should have_content("Do you want to assign it to them anyway?") }
            it { should have_button('Assign Shift') }  
            it { should have_link('Cancel') }
          end

          describe "clicking 'Cancel'" do
            before { click_link 'Cancel' }
            it "should not assign the shift to the rider" do
              expect( rider.reload.shifts.include? next_day_shift ).to eq false
              expect( next_day_shift.assignment ).to eq nil
            end
          end

          describe "clicking 'Assign Shift'" do
            before { click_button 'Assign Shift' }

            it "should assign the shift to the rider" do
              expect( rider.reload.shifts.include? next_day_shift ).to eq true
              expect( next_day_shift.assignment ).not_to eq nil
              expect( next_day_shift.assignment.rider ).to eq rider
            end
            it { should have_success_message("Shift assigned to #{rider.name}") }
            it { should have_h1('Shifts') }
          end
        end

        describe "making new assignment to rider with double-booking" do
          before do
            same_time_shift.assign_to rider
            visit new_shift_assignment_path(shift)
            make_valid_assignment_submission
          end

          describe "override page contents" do
            it { should have_h1('Double Booking Alert') }
            it { should have_content("You tried to assign the following shift:") }
            it { should have_content( same_time_shift.start.strftime( "%m/%d | %I:%M%p" ) ) }  
            it { should have_content("to #{rider.contact.name}, which would double book them with the following shift(s):") }
            it { should have_content(same_time_shift.start.strftime("%m/%d | %I:%M%p")) }
            it { should have_content("Do you want to assign it to them anyway?") }
            it { should have_button('Assign Shift') }  
            it { should have_link('Cancel') }
          end

          describe "clicking 'Cancel'" do
            before { click_link 'Cancel' }
            it "should not assign the shift to the rider" do
              expect( rider.reload.shifts.include? shift ).to eq false
              expect( shift.assignment ).to eq nil
            end
          end

          describe "clicking 'Assign Shift'" do
            before { click_button 'Assign Shift' }

            it "should assign the shift to the rider" do
              expect( rider.reload.shifts.include? shift ).to eq true
              expect( shift.assignment ).not_to eq nil
              expect( shift.assignment.rider ).to eq rider
            end
            it { should have_success_message("Shift assigned to #{rider.name}") }
          end
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

      describe "reassigning shift to rider with conflict" do
        before do
          conflict # on next day
          next_day_shift.assign_to other_rider
          visit edit_shift_assignment_path(next_day_shift, next_day_shift.assignment)
          select rider.contact.name, from: 'assignment_rider_id'
          click_button submit
        end

        describe "override page contents" do
          it { should have_h1('Conflict Alert') }
          it { should have_content("You tried to assign the following shift:") }
          it { should have_content( next_day_shift.start.strftime( "%m/%d | %I:%M%p" ) ) }  
          it { should have_content("to #{rider.contact.name}, who has the following conflict(s):") }
          it { should have_content(conflict.start.strftime("%m/%d | %I:%M%p")) }
          it { should have_content("Do you want to assign it to them anyway?") }
          it { should have_button('Assign Shift') }  
          it { should have_link('Cancel') }
        end

        # describe "clicking 'Cancel'" do  
        #   before { click_link('Cancel') }            
        #   it { should have_h1("Shifts") } 
        #   # redirect to right page
        # end

        # describe "clicking 'Assign Shift'" do
        #   before { click_button('Assign Shift') }              
          

        #   it { should have_success_message("Assignment updated (Rider: #{rider.name}, Status: #{next_day_shift.assignment.status.text})") }
        #   it { should have_h1("Shifts") } 

        #   describe "updating assignment attributes" do
        #     subject { next_day_shift.assignment.reload }

        #     its(:rider) { should eq rider }         
        #   end
        # end
        describe "clicking 'Cancel'" do
          before{ click_link 'Cancel' }

          it "should not change the assignment" do
            expect( other_rider.reload.shifts.include? next_day_shift ).to eq false
            expect( rider.reload.shifts.include? next_day_shift ).to eq true
            expect( next_day_shift.assignment.reload.rider ).not_to eq other_rider
            expect( next_day_shift.assignment.reload.rider ).to eq rider                            
          end
        end

        describe "clicking 'Assign Shift'" do
          before { click_button 'Assign Shift' }

          it "should assign the shift to the rider" do
            expect( other_rider.reload.shifts.include? next_day_shift ).to eq false
            expect( rider.reload.shifts.include? next_day_shift ).to eq true
            expect( next_day_shift.assignment.reload.rider ).not_to eq other_rider
            expect( next_day_shift.assignment.reload.rider ).to eq rider  
          end
        end

      end

      describe "reassigning shift to rider with double-booking" do
          before do
            same_time_shift.assign_to other_rider
            visit edit_shift_assignment_path(shift, shift.assignment)
            select other_rider.contact.name, from: 'assignment_rider_id'
            click_button submit
          end

          describe "override page contents" do
            it { should have_h1('Double Booking Alert') }
            it { should have_content("You tried to assign the following shift:") }
            it { should have_content( same_time_shift.start.strftime( "%m/%d | %I:%M%p" ) ) }  
            it { should have_content("to #{other_rider.contact.name}, which would double book them with the following shift(s):") }
            it { should have_content(same_time_shift.start.strftime("%m/%d | %I:%M%p")) }
            it { should have_content("Do you want to assign it to them anyway?") }
            it { should have_button('Assign Shift') }  
            it { should have_link('Cancel') }
          end

          describe "clicking 'Cancel'" do
            before{ click_link 'Cancel' }

            it "should not change the assignment" do
              expect( other_rider.reload.shifts.include? shift ).to eq false
              expect( rider.reload.shifts.include? shift ).to eq true
              expect( assignment.reload.rider ).not_to eq other_rider
              expect( assignment.reload.rider ).to eq rider                            
            end
          end

          describe "clicking 'Assign Shift'" do
            before { click_button 'Assign Shift' }

            it "should assign the shift to the rider" do
              expect( other_rider.reload.shifts.include? shift ).to eq true
              expect( rider.reload.shifts.include? shift ).to eq false
              expect( assignment.reload.rider ).to eq other_rider
              expect( assignment.reload.rider ).not_to eq rider
            end
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