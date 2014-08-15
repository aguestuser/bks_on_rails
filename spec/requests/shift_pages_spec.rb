require 'spec_helper'
include CustomMatchers
include RequestSpecMacros
include ShiftRequestMacros

describe "Shift Requests" do
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let!(:other_restaurant) { FactoryGirl.create(:restaurant) }
  let(:shift) { FactoryGirl.build(:shift, :with_restaurant, restaurant: restaurant) }
  let(:shifts) { 31.times.map { FactoryGirl.create(:shift, :without_restaurant) } }
  let(:staffer) { FactoryGirl.create(:staffer) }
  before { mock_sign_in staffer }

  subject { page }

  describe "display pages" do
    
    describe "Shifts#show" do
      before do
        shift.save
        visit shift_path shift
      end      
      
      describe "page contents" do
        it { should have_h3('Shift Details') }
        it { should have_content('Restaurant:') }
        it { should have_content('Start:') }
        it { should have_content('End:') }
        it { should have_content('Urgency:') }
        it { should have_content('Billing:') }
        it { should have_content('Notes:') }
      end
    end

    describe "Shifts#index" do
      before do
        FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant)
        FactoryGirl.create(:shift, :with_restaurant, restaurant: other_restaurant)
      end 
      # after(:all) { Shift.last(2).each { |s| s.destroy } }
      # let(:shifts) { Shift.last(2) }
      # let(:first_restaurant) { shifts[0].restaurant }
      # let(:second_restaurant) { shifts[1].restaurant }

      describe "from root path" do

        before do 
          visit shifts_path 
          filter_shifts_by_time_inclusively
        end

        let(:first_shift){ 
          FactoryGirl.create(:shift, 
            :with_restaurant, 
            restaurant: restaurant,
            start: Time.zone.local(2012,1,1,11),
            :end => Time.zone.local(2012,1,1,16)
          )
        }
        let(:second_shift){
          FactoryGirl.create(:shift, 
            :with_restaurant, 
            restaurant: other_restaurant,
            start: Time.zone.local(2016,1,1,12),
            :end => Time.zone.local(2016,1,1,16)
          )
        }
        let(:dummy_shift){
          FactoryGirl.create(:shift, 
            :with_restaurant, 
            restaurant: other_restaurant,
            start: Time.zone.local(2014,1,1,13),
            :end => Time.zone.local(2014,1,1,16)
          )
        }
        let(:rider){ FactoryGirl.create(:rider) }
        let(:other_rider){ FactoryGirl.create(:rider) }

        describe "page contents" do

          it { should have_h1('Shifts')}
          it { should have_link('Create shift') }
          it { should have_content('Restaurant') }
          it { should have_link('Action') }
          it { should have_content(restaurant.mini_contact.name) }
          it { should have_content(other_restaurant.mini_contact.name) }          
        end

        describe "PAGINATION" do
          before do
            shifts
            visit shifts_path
          end

          it { should_not have_content format_start(shifts[30].start) }
        end

        describe "SORTING" do
          before do
            configure_shifts_for_sort_tests
            visit shifts_path
            filter_shifts_by_time_inclusively
            # page.all('div.restaurant').each { |div| puts div.text }
          end

          it "should order shifts by time by default" do
            expect( page.all('div.time')[0].text ).to eq first_shift.table_time
          end

          describe "sorting by restaurant name" do
            describe "ascending" do
              before { click_link('Restaurant') }
              
              it "should sort by restaurants, ascending" do
                expect( page.all('div.restaurant')[0].text ).to eq restaurant.name
              end

              describe "descending" do
                before do  
                  click_link('Restaurant') 
                end           

                it "should sort by restaurant name, descending" do
                  expect( page.all('div.restaurant')[0].text ).to eq other_restaurant.name
                end  
              end
            end
          end

          describe "sorting by time" do
            describe "descending" do
              before { click_link('Time') }
              
              it "should sort by time, descending" do
                expect( page.all('div.time')[0].text ).to eq second_shift.table_time
              end
              
              describe "descending" do
                before { click_link('Time') }            

                it "should sort by time, ascending" do
                  expect( page.all('div.time')[0].text ).to eq first_shift.table_time
                end  
              end
            end
          end

          describe "sorting by rider name" do
            describe "ascending" do
              before { click_link('Assigned to') }
              
              it "should sort by riders, ascending" do
                expect( page.all('div.rider')[0].text ).to eq rider.name
              end

              describe "descending" do
                before { click_link('Assigned to') }            

                it "should sort by rider name, descending" do
                  expect( page.all('div.rider')[0].text ).to eq '--'
                end  
              end
            end
          end

          describe "sorting by assignment status" do
            describe "ascending" do
              before { click_link('Status') }
              
              it "should sort by statuses, ascending" do
                expect( page.all('div.status')[0].text ).to eq AssignmentStatus::CancelledByRestaurant.new.text
              end

              describe "descending" do
                before { click_link('Status') }            

                it "should sort by statuses, descending" do
                  expect( page.all('div.status')[0].text ).to eq AssignmentStatus::Unassigned.new.text
                end 
              end
            end
          end
        end

        describe "FILTERING" do
          before do
            configure_shifts_for_sort_tests
            visit shifts_path
            # page.all('div.time').each { |div| puts div.text }
          end
          
          describe "by time" do
            before { filter_shifts_by_time_inclusively } # for default view

            describe "before filtering" do

              it "should include first shift" do
                expect( page.all('div.time')[0].text ).to eq first_shift.table_time
              end

              describe "after sorting by time (descending)" do
                before { click_link 'Time' }

                it "should include second shift" do
                  expect( page.all('div.time')[0].text ).to eq second_shift.table_time
                end  
              end
            end

            describe "after filtering" do
              before { filter_shifts_by_time_exclusively }

              it "should exclude first shift" do
                expect( page.all('div.time')[0].text ).not_to eq first_shift.table_time
              end

              describe "after sorting by time, descending" do
                before { click_link 'Time' }

                it "should exclude second shift" do
                  expect( page.all('div.time')[0].text ).not_to eq second_shift.table_time
                end
              end              
            end
          end

          describe "by restaurant" do
            before { filter_shifts_by_time_inclusively } # for default view

            describe "before filtering" do

              describe "after sorting by restaurant (ascending)" do
                before { click_link 'Restaurant' }

                it "should include first shift" do
                  expect( page.all('div.restaurant')[0].text ).to eq first_shift.restaurant.name
                end

                describe "after sorting by restaurant (descending)" do
                  before { click_link 'Restaurant' }

                  it "should include second shift" do
                    expect( page.all('div.restaurant')[0].text ).to eq second_shift.restaurant.name
                  end                
                end
              end
            end

            describe "after filtering for 2nd rest (and sorting by rest asc)" do
              before do 
                filter_shifts_by_restaurant [ second_shift.restaurant ] 
                click_link 'Restaurant'
              end

              it "should exclude first shift" do
                expect( page.all('div.restaurant')[0].text ).not_to eq first_shift.restaurant.name
              end
            end

            describe "after filtering for 1st rest. (& sorting by rest desc)" do
              before do 
                filter_shifts_by_restaurant [ first_shift.restaurant ]
                click_link 'Restaurant'
                click_link 'Restaurant'
              end

              it "should exclude first shift" do
                expect( page.all('div.restaurant')[0].text ).not_to eq second_shift.restaurant.name
              end
            end
          end


          describe "by rider" do
            before { filter_shifts_by_time_inclusively } # for default view

            describe "before filtering" do

              describe "after sorting by rider (ascending)" do
                before { click_link 'Assigned to' }

                it "should include first shift" do
                  expect( page.all('div.rider')[0].text ).to eq first_shift.assignment.rider.name
                end

                describe "after sorting by rider (descending)" do
                  before { click_link 'Assigned to' }

                  it "should include second shift" do
                    expect( page.all('div.rider')[0].text ).to eq '--'
                  end                
                end
              end
            end  

            describe "after filtering for 2nd rider (and sorting by rider asc)" do
              before do 
                filter_shifts_by_rider [ second_shift.assignment.rider ] 
                click_link 'Assigned to'
              end

              it "should exclude first shift" do
                expect( page.all('div.rider')[0].text ).not_to eq first_shift.assignment.rider.name
              end
            end

            describe "after filtering for 1st rider (& sorting by rider desc)" do
              before do 
                filter_shifts_by_rider [ first_shift.assignment.rider ]
                click_link 'Assigned to'
                click_link 'Assigned to'
              end
              it "should exclude first shift" do
                expect( page.all('div.rider')[0].text ).not_to eq '--'
              end
            end
          end

          describe "by status" do
            before do 
              filter_shifts_by_time_inclusively # for default view
              filter_shifts_by_restaurant [ first_shift.restaurant, second_shift.restaurant ]
            end
            
            describe "before filtering" do

              describe "after sorting by status (ascending)" do
                before { click_link 'Status' }

                it "should include first shift" do
                  expect( page.all('div.status')[0].text ).to eq first_shift.assignment.status.text
                end

                describe "after sorting by rider (descending)" do
                  before { click_link 'Status' }

                  it "should include second shift" do
                    expect( page.all('div.status')[0].text ).to eq second_shift.assignment.status.text
                  end                
                end
              end
            end  

            describe "after filtering for 2nd status (and sorting by status asc)" do
              before do 
                filter_shifts_by_status [ second_shift.assignment.status.text ] 
                click_link 'Status'
              end

              it "should exclude first shift" do
                expect( page.all('div.status')[0].text ).not_to eq first_shift.assignment.status.text
              end
            end

            describe "after filtering for 1st status (& sorting by status desc)" do
              before do 
                filter_shifts_by_status [ first_shift.assignment.status.text ]
                click_link 'Status'
                click_link 'Status'
              end
              it "should exclude first shift" do
                expect( page.all('div.status')[0].text ).not_to eq second_shift.assignment.status.text
              end
            end
          end
        end
      end

      describe "from restaurant path" do
        before { visit restaurant_shifts_path(restaurant) }
        it { should have_content(restaurant.mini_contact.name) }
        it { should_not have_content(other_restaurant.mini_contact.name) }
      end
    end
  end

  describe "form pages" do
    
    describe "Shifts#new" do
      
      let(:submit) { 'Create shift' }
      let(:models) { [ Shift ] }
      let!(:old_counts) { count_models models }

      describe "from root path" do
        before { visit new_shift_path }

        it "should have correct form fields" do
          check_shift_form_contents 'root'
        end

        describe "form submission" do

          describe "with invalid input" do
            before { make_invalid_shift_submission }

            it { should have_an_error_message }
          end

          describe "with valid input" do
            before { make_valid_shift_submission }

            describe "after submission" do
              let(:new_counts){ count_models models }
              it "should create a new shift" do
                expect( model_counts_incremented? old_counts, new_counts ).to eq true 
              end
              it "should give the shift a blank assignment" do
                expect( shift.assignment.nil? ).to eq false
              end
              it { should have_success_message('Shift created') }
              it { should have_h1('Shifts') }                
            end
          end
        end
      end

      describe "from restaurant path" do
        before { visit new_restaurant_shift_path(restaurant) }

        it { should_not have_label('Restaurant') }
      end
    end

    describe "Shifts#edit" do
      
      let(:submit) { 'Save changes' }

      describe "from shifts path" do

        before do 
          shift.save
          visit edit_shift_path(shift) 
        end
        
        it "should have correct form fields" do
          check_shift_form_contents 'root'
        end 

        describe "with invalid input" do
          before { make_invalid_shift_submission }

          it { should have_an_error_message }
        end

        describe "with valid input" do
          before { make_valid_shift_submission }

          it { should have_success_message('Shift updated') }
          it { should have_h1('Shifts') }
        end
      end

      describe "from restaurants path" do
        it { should_not have_label('Restaurant') }
      end
    end
  end
end