require 'spec_helper'
include CustomMatchers, RequestSpecMacros, AssignmentRequestMacros, ShiftRequestMacros

describe "Assignment Requests" do
  let(:staffer) { FactoryGirl.create(:staffer) }
  let(:rider) { FactoryGirl.create(:rider) }
  let(:other_rider) { FactoryGirl.create(:rider) }

  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let!(:other_restaurant) { FactoryGirl.create(:restaurant) }

  let(:start){ Time.zone.local(2014,1,1,11) }
  let(:_end){ Time.zone.local(2014,1,1,17) }

  let!(:shift){ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start, :end => _end) }
  let!(:next_day_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant, start: start + 1.day, :end => _end + 1.day) }
  let(:same_time_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: other_restaurant, start: start, :end => _end) }
  let(:conflict){ FactoryGirl.create(:conflict, rider: rider, start: start + 1.day, :end => _end + 1.day) }

  # let(:assignment) { Assignment.new( rider_id: rider.id, shift_id: shift.id) }
  # let(:other_assignment) { Assignment.new( rider_id: rider.id, shift_id: next_day_shift.id) }

  let(:assignment_start) { shift.start.strftime("%m/%d | %I:%M%p") }
  let(:assignment_end) { shift.end.strftime("%I:%M%p") }

  before { mock_sign_in staffer }

  subject { page }

  describe "Assignments#show" do
    before { shift.assign_to rider }

    describe "from root path" do
      before { visit shift_assignment_path(shift, shift.assignment) }

      describe "page contents" do

        it { should have_h3('Assignment Details') }
        it { should have_content('Shift:') }
        it { should have_content('Assigned to:') }
        it { should have_content('Status:') }
        it { should have_h3('Assignment History') }
        it { should have_link('Edit', href: "/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit?base_path=/shifts/") }
      end

      describe "editing assignment from show page" do
        before { click_link 'Edit' }

        its(:current_path) { should eq "/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit" }
        it { should have_h1("Edit Shift Assignment") }

        describe "saving (no) changes" do
          before { click_button 'Save changes' }

          its(:current_path) { should eq "/shifts/" }
          it { should have_h1("Shifts") }
        end
      end      
    end

    describe "from restaurants path" do
      before { visit restaurant_shift_assignment_path(shift.restaurant, shift, shift.assignment) }
      
      it { should have_link('Edit', href: "/restaurants/#{shift.restaurant.id}/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit?base_path=/restaurants/#{shift.restaurant.id}/shifts/") }

      describe "editing assignment from show page" do
        before { click_link 'Edit' }

        its(:current_path) { should eq "/restaurants/#{shift.restaurant.id}/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit" }
        it { should have_h1 'Edit Shift Assignment' }

        describe "saving changes" do
          before { click_button 'Save changes' }

          its(:current_path){ should eq "/restaurants/#{shift.restaurant.id}/shifts/" }
          it { should have_h1 "Shifts for #{shift.restaurant.name}" }          
        end
      end
    end

    describe "from riders path" do
      before { visit rider_shift_assignment_path(shift.rider, shift, shift.assignment) }
      
      it { should have_link('Edit', href: "/riders/#{shift.rider.id}/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit?base_path=/riders/#{shift.rider.id}/shifts/") }

      describe "editing assignment from show page" do
        before { click_link 'Edit' }

        its(:current_path) { should eq "/riders/#{shift.rider.id}/shifts/#{shift.id}/assignments/#{shift.assignment.id}/edit" }
        it { should have_h1 'Edit Shift Assignment' }

        describe "saving changes" do
          before { click_button 'Save changes' }

          its(:current_path){ should eq "/riders/#{shift.rider.id}/shifts/" }
          it { should have_h1 "Shifts for #{shift.rider.name}" }          
        end
      end
    end    
  end # "Assignments#show"

  describe "Assignments in Shifts#index" do

    describe "from root path" do

      before do 
        next_day_shift.unassign
        visit shifts_path
        filter_shifts_by_time_inclusively
      end

      describe "page contents" do

        it { should have_link('Restaurant') } 
        it { should have_link(shift.restaurant.mini_contact.name) }
        it { should have_link('Time') }
        it { should have_content(shift.table_time) }
        it { should have_link('Assigned to') }
        it { should have_link(shift.assignment.rider.contact.name) }
        it { should have_link('Status') }
        it { should have_content(shift.assignment.status.text) }
        it { should have_link('Edit Assignment') }
        it { should have_link('Assignment Details') }
        it { should have_link('Assign Shift') }
        it { should have_link('Create shift') }
        
        describe "with unassigned shift" do
          it { should have_content('--') }
          it { should have_link('Assign Shift') }
        end
      end
    end

    describe "from restaurant path" do
      
      before do
        visit restaurant_shifts_path(restaurant)
        filter_shifts_by_time_inclusively
      end

      it { should_not have_row_header('Restaurant') }
      it { should have_row_header('Time')}
      it { should have_row_header('Assigned to')}
      it { should have_row_header('Status')}
      it { should have_link('Create shift') }
      it { should have_link('All shifts') }
    end

    describe "from rider path" do
      
      before do
        visit rider_shifts_path(rider)
        filter_shifts_by_time_inclusively
      end

      it { should have_row_header('Restaurant') }
      it { should have_content(restaurant.mini_contact.name) }
      it { should_not have_content('Assigned to')}
      it { should_not have_content('--') }
      it { should_not have_link('Create new shift') }      
      it { should have_link('All shifts') }
    end # "from rider path"
  end # "Assignments in Shifts#index"

  describe "Assignments#EDIT" do
    before { shift.assign_to rider }
    let(:submit) { 'Save changes' }

    describe "from SHIFTS PATH" do
      before { visit edit_shift_assignment_path(shift, shift.assignment) }

      describe "page contents" do
        check_assignment_form_contents :edit
      end

      describe "assigning to rider WITHOUT OBSTACLES" do
        before { make_valid_assignment_edit }

        describe "updating assignment attributes" do
          subject { shift.assignment.reload }

          its(:rider) { should eq Rider.first }
          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider }          
        end

        describe "success redirect" do
          subject { page }
          
          it { should have_success_message("Assignment successfully edited") }
          it { should have_h1("Shifts") } 
        end # 
      end # "assigning to rider WITHOUT OBSTACLES"

      describe "assigning to rider with CONFLICT" do
        before do
          conflict # on next day, belongs to rider
          next_day_shift.assign_to other_rider
          visit edit_shift_assignment_path(next_day_shift, next_day_shift.assignment)
          select rider.contact.name, from: 'assignment_rider_id'
          click_button submit
        end

        describe "Resolve Obstacles page" do

          describe "CONTENTS" do
            
            it "should be the Resolve Obstacles page" do
              expect(current_path).to eq "/shifts/#{next_day_shift.id}/assignments/#{next_day_shift.assignment.id}"
              expect(page).to have_h1 'Resolve Scheduling Obstacles'
            end

            it "should correctly list Assignments With Conflicts" do
              expect(page.within("#assignments_with_conflicts"){ find("h3").text }).to eq "Assignments With Conflicts"
              expect(page.all("#assignments_with_conflicts_0 .shift_box")[0].text).to eq "#{next_day_shift.table_time} @ #{restaurant.name}"
              expect(page.all("#assignments_with_conflicts_0 .shift_box")[1].text).to eq "Assigned to: #{rider.name} [Proposed]"
              expect(page.all("#assignments_with_conflicts_0 .shift_box")[2].text).to eq conflict.table_time
              expect(page.find("#decisions_0_Accept")).to be_checked
              expect(page.find("#decisions_0_Override")).to_not be_checked   
            end

            it "should not list Assignments With Double Bookings" do
              expect(page).not_to have_selector("#assignments_with_double_bookings")
            end

            it "should note list Assignments Without Obstacles" do
              expect(page).not_to have_selector("#assignments_without_obstacles")
            end
          end # "CONTENTS"
        end # "Resolve Obstacles page"

        describe "OVERRIDING" do
          before do   
            choose 'decisions_0_Override'
            click_button 'Submit'
          end

          it "should assign the shift to the rider" do
            expect( other_rider.reload.shifts.include? next_day_shift ).to eq false
            expect( rider.reload.shifts.include? next_day_shift ).to eq true
            expect( next_day_shift.assignment.reload.rider ).not_to eq other_rider
            expect( next_day_shift.assignment.reload.rider ).to eq rider  
          end
        end # "OVERRIDING"

        describe "ACCEPTING" do
          before do   
            choose 'decisions_0_Accept'
            click_button 'Submit'
          end

          describe "Batch Reassign Page" do
            let(:batch){ [ next_day_shift ] }
            
            it "should be the batch reassign page" do
              expect(current_path).to eq '/assignment/resolve_obstacles'
              expect(page).to have_h1 'Batch Reassign Shifts'                         
            end

            it "should correctly list Assignements Requiring Reassignment" do
              check_reassign_single_shift_list rider, 'Proposed', 0
            end

            it "should not change the assignment" do
              expect( other_rider.reload.shifts.include? next_day_shift ).to eq true
              expect( rider.reload.shifts.include? next_day_shift ).to eq false
              expect( next_day_shift.assignment.reload.rider ).to eq other_rider
              expect( next_day_shift.assignment.reload.rider ).not_to eq rider                            
            end
          end # "Batch Reassign Page"
        end # "ACCEPTING"
      end # "assigning shift to rider with CONFLICT"

      describe "assigning to rider with DOUBLE BOOKING" do
        let(:batch){ [shift] }
        let(:double_bookings){ [same_time_shift] }
        before do
          same_time_shift.assign_to other_rider
          same_time_shift.assignment.update(status: :proposed)
          visit edit_shift_assignment_path(shift, shift.assignment)
          select other_rider.contact.name, from: 'assignment_rider_id'
          click_button submit
        end

        describe "Resolve Obstacles page" do
          
          describe "CONTENTS" do
            
            it "should be the Resolve Obstacles page" do
              expect(current_path).to eq "/shifts/#{shift.id}/assignments/#{shift.assignment.id}"
              expect(page).to have_h1 'Resolve Scheduling Obstacles'
            end

            it "should not list Assignments With Conflicts" do
              expect(page).not_to have_selector("#assignments_with_conflicts") 
            end

            it "should correctly list Assignments With Double Bookings" do
              check_assignments_with_double_booking_list [0], [0]
            end

            it "should note list Assignments Without Obstacles" do
              expect(page).not_to have_selector("#assignments_without_obstacles")
            end
          end # "CONTENTS"

          describe "OVERRIDING" do
            before do   
              choose 'decisions_0_Override'
              click_button 'Submit'
            end

            it "should assign the shift to the rider" do
              expect( other_rider.reload.shifts.include? shift ).to eq true
              expect( rider.reload.shifts.include? shift ).to eq false
              expect( shift.assignment.reload.rider ).to eq other_rider
              expect( shift.assignment.reload.rider ).not_to eq rider
            end
          end # "OVERRIDING"

          describe "ACCEPTING" do
            before do
              choose 'decisions_0_Accept'
              click_button 'Submit'
            end

            describe "Batch Reassign Page" do
              
              it "should be the batch reassign page" do
                expect(current_path).to eq '/assignment/resolve_obstacles'
                expect(page).to have_h1 'Batch Reassign Shifts'                         
              end

              it "should correctly list Assignements Requiring Reassignment" do
                check_reassign_single_shift_list other_rider, 'Proposed', 0
              end

              it "should not change the assignment" do
                expect( other_rider.reload.shifts.include? shift ).to eq false
                expect( rider.reload.shifts.include? shift ).to eq true
                expect( shift.assignment.reload.rider ).not_to eq other_rider
                expect( shift.assignment.reload.rider ).to eq rider                            
              end
            end # "Batch Reassign Page"
          end # "ACCEPTING"
        end # "Resolve Obstacles page"
      end # "assigning to rider with DOUBLE BOOKING"
    end # "from SHIFTS path"

    describe "from restaurant path" do
      before { visit edit_restaurant_shift_assignment_path(restaurant, shift, shift.assignment) }

      describe "page contents" do
        check_assignment_form_contents :edit, :restaurant
      end

      describe "with valid input" do
        before { make_valid_assignment_edit }

        describe "updating assignment attributes" do
          subject { shift.assignment.reload }

          its(:rider) { should eq Rider.first }
          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider }
        end

        describe "success redirect" do
          subject { page }

          it { should have_success_message("Assignment successfully edited") }
          it { should have_h1("Shifts for #{restaurant.name}") } 
        end
      end
    end # "from restaurant path"

    describe "from riders path" do
      before { visit edit_rider_shift_assignment_path(rider, shift, shift.assignment) }      

      describe "page contents" do
        check_assignment_form_contents :edit, :rider        
      end

      describe "with valid input" do
        before { make_valid_assignment_edit :rider }

        describe "updating assignment attributes" do
          subject { shift.assignment.reload }

          its(:status) { should be_an_instance_of AssignmentStatus::CancelledByRider } 
        end

        describe "success redirect" do
          subject { page }

          it { should have_success_message("Assignment successfully edited") }
          it { should have_h1("Shifts for #{rider.name}") }
        end
      end
    end # "from riders path"
  end # "Assignments#EDIT"
end