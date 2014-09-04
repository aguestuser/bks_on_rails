require 'spec_helper'
include CustomMatchers, RequestSpecMacros, ShiftRequestMacros, GridRequestMacros

describe "Shift Requests" do
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let!(:other_restaurant) { FactoryGirl.create(:restaurant) }
  let!(:rider){ FactoryGirl.create(:rider) }
  let!(:other_rider){ FactoryGirl.create(:rider) }
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
            expect( page.find('#row_1_col_2').text ).to eq first_shift.table_time
          end

          describe "sorting by restaurant name" do
            describe "ascending" do
              before { click_link('Restaurant') }
              
              it "should sort by restaurants, ascending" do
                expect( page.find('#row_1_col_1').text ).to eq restaurant.name
              end

              describe "descending" do
                before do  
                  click_link('Restaurant') 
                end           

                it "should sort by restaurant name, descending" do
                  expect( page.find('#row_1_col_1').text ).to eq other_restaurant.name
                end  
              end
            end
          end

          describe "sorting by time" do
            describe "descending" do
              before { click_link('Time') }
              
              it "should sort by time, descending" do
                expect( page.find('#row_1_col_2').text ).to eq second_shift.table_time
              end
              
              describe "descending" do
                before { click_link('Time') }            

                it "should sort by time, ascending" do
                  expect( page.find('#row_1_col_2').text ).to eq first_shift.table_time
                end  
              end
            end
          end

          describe "sorting by rider name" do
            describe "ascending" do
              before { click_link('Assigned to') }
              
              it "should sort by riders, ascending" do
                expect( page.find('#row_1_col_3').text ).to eq rider.name
              end

              describe "descending" do
                before { click_link('Assigned to') }            

                it "should sort by rider name, descending" do
                  expect( page.find('#row_1_col_3').text ).to eq '--'
                end  
              end
            end
          end

          describe "sorting by assignment status" do
            describe "ascending" do
              before { click_link('Status') }
              
              it "should sort by statuses, ascending" do
                expect( page.find('#row_1_col_4').text ).to eq AssignmentStatus::CancelledByRestaurant.new.text
              end

              describe "descending" do
                before { click_link('Status') }            

                it "should sort by statuses, descending" do
                  expect( page.find('#row_1_col_4').text ).to eq AssignmentStatus::Unassigned.new.text
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
                expect( page.find('#row_1_col_2').text ).to eq first_shift.table_time
              end

              describe "after sorting by time (descending)" do
                before { click_link 'Time' }

                it "should include second shift" do
                  expect( page.find('#row_1_col_2').text ).to eq second_shift.table_time
                end  
              end
            end

            describe "after filtering" do
              before { filter_shifts_by_time_exclusively }

              it "should exclude first shift" do
                expect( page.find('#row_1_col_2').text ).not_to eq first_shift.table_time
              end

              describe "after sorting by time, descending" do
                before { click_link 'Time' }

                it "should exclude second shift" do
                  expect( page.find('#row_1_col_2').text ).not_to eq second_shift.table_time
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
                  expect( page.find('#row_1_col_1').text ).to eq first_shift.restaurant.name
                end

                describe "after sorting by restaurant (descending)" do
                  before { click_link 'Restaurant' }

                  it "should include second shift" do
                    expect( page.find('#row_1_col_1').text ).to eq second_shift.restaurant.name
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
                expect( page.find('#row_1_col_1').text ).not_to eq first_shift.restaurant.name
              end
            end

            describe "after filtering for 1st rest. (& sorting by rest desc)" do
              before do 
                filter_shifts_by_restaurant [ first_shift.restaurant ]
                click_link 'Restaurant'
                click_link 'Restaurant'
              end

              it "should exclude first shift" do
                expect( page.find('#row_1_col_1').text ).not_to eq second_shift.restaurant.name
              end
            end
          end


          describe "by rider" do
            before { filter_shifts_by_time_inclusively } # for default view

            describe "before filtering" do

              describe "after sorting by rider (ascending)" do
                before { click_link 'Assigned to' }

                it "should include first shift" do
                  expect( page.find('#row_1_col_3').text ).to eq first_shift.assignment.rider.name
                end

                describe "after sorting by rider (descending)" do
                  before { click_link 'Assigned to' }

                  it "should include second shift" do
                    expect( page.find('#row_1_col_3').text ).to eq '--'
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
                expect( page.find('#row_1_col_3').text ).not_to eq first_shift.assignment.rider.name
              end
            end

            describe "after filtering for 1st rider (& sorting by rider desc)" do
              before do 
                filter_shifts_by_rider [ first_shift.assignment.rider ]
                click_link 'Assigned to'
                click_link 'Assigned to'
              end
              it "should exclude first shift" do
                expect( page.find('#row_1_col_3').text ).not_to eq '--'
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
                  expect( page.find('#row_1_col_4').text ).to eq first_shift.assignment.status.text
                end

                describe "after sorting by rider (descending)" do
                  before { click_link 'Status' }

                  it "should include second shift" do
                    expect( page.find('#row_1_col_4').text ).to eq second_shift.assignment.status.text
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
                expect( page.find('#row_1_col_4').text ).not_to eq first_shift.assignment.status.text
              end
            end

            describe "after filtering for 1st status (& sorting by status desc)" do
              before do 
                filter_shifts_by_status [ first_shift.assignment.status.text ]
                click_link 'Status'
                click_link 'Status'
              end
              it "should exclude first shift" do
                expect( page.find('#row_1_col_4').text ).not_to eq second_shift.assignment.status.text
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

  describe "BATCH REQUESTS" do
    before { restaurant }
    
    let!(:old_count){ Shift.count }

    let(:start_t){ Time.zone.local(2014,1,1,12) }
    let(:end_t){ Time.zone.local(2014,1,1,18) }

    let!(:batch)do
      3.times.map do |n|
        FactoryGirl.build(:shift, :with_restaurant, restaurant: restaurant, start: start_t + n.days, :end => end_t + n.days)
      end
    end
    subject { page }
    
    describe "BATCH CREATE" do
      
      describe "clone page" do 
        before { visit '/shift/clone_new' }

        describe "page contents" do
          
          it { should have_h1('Batch Create Shifts -- Base Shift') }
          it "should have correct shift form labels" do 
            check_shift_form_contents 'root' 
          end
          it "should have correct batch shift selects" do
            check_batch_shift_selects
          end
          it { should have_label 'Number of Clones to Make:' }
          it { should have_select 'num_shifts' }
        end
        
        describe "batch create page" do
          before { make_base_shift }

          describe "page contents" do
            
            it "should have correct uri" do 
              expect(current_path).to eq "/shift/batch_new"
              expect(URI.parse(current_url).to_s).to include("?utf8=%E2%9C%93&shifts[][id]=&shifts[][restaurant_id]=#{restaurant.id}")
            end
            
            it { should have_h1 'Batch Create Shifts' }
            it { should have_content(restaurant.name) }

            it "should have correct start dates" do
              expect(page.all("#shifts__start_day")[0].find('option[selected]').text).to eq batch[0].start.day.to_s
              expect(page.all("#shifts__start_day")[1].find('option[selected]').text).to eq batch[1].start.day.to_s
              expect(page.all("#shifts__start_day")[2].find('option[selected]').text).to eq batch[2].start.day.to_s
            end
          end

          describe "executing batch create" do
            before do 
              click_button 'Save changes' 
            end

            it "should create 3 new shifts" do
              expect(Shift.count).to eq old_count + 3
            end
            it "should have correct URI" do 
              expect(current_path).to include '/shifts'
            end

            describe "shift listings" do
              before { filter_shifts_by_time_inclusively }
              
              it "should show new shifts" do
                expect(page.find("#row_1_col_2").text).to eq batch[0].table_time
                expect(page.find("#row_2_col_2").text).to eq batch[1].table_time
                expect(page.find("#row_3_col_2").text).to eq batch[2].table_time
              end
            end
          end     
        end 
      end
    end  

    describe "BATCH EDIT" do
      before { batch.each(&:save) }

      describe "from shifts index" do
        before do 
          visit shifts_path
          filter_shifts_by_time_inclusively 
        end

        describe "page contents" do
          it { should have_button 'Batch Edit' }
          it { should have_button 'Batch Assign' }
          it "should have correct form action" do
            expect(page.find("form.batch")['action']).to eq '/shift/batch_edit'
          end
          it "should have correct checkbox id values" do
            expect( page.within( "#row_1" ) { find("#ids_")['value'] } ).to eq batch[0].id.to_s
            expect( page.within( "#row_2" ) { find("#ids_")['value'] } ).to eq batch[1].id.to_s
            expect( page.within( "#row_3" ) { find("#ids_")['value'] } ).to eq batch[2].id.to_s
          end          
        end

        describe "batch edit shift page" do
          before do
            page.within("#row_1"){ find("#ids_").set true }
            page.within("#row_2"){ find("#ids_").set true }
            page.within("#row_3"){ find("#ids_").set true } 
            click_button 'Batch Edit', match: :first
          end

          describe "page contents" do 
            it "should have correct URI" do 
              expect(current_path).to eq "/shift/batch_edit"
              expect(URI.parse(current_url).to_s).to include("&ids[]=#{batch[0].id}&ids[]=#{batch[1].id}&ids[]=#{batch[2].id}&commit=Batch+Edit")
            end
            
            it { should have_h1 'Batch Edit Shifts' }
            it { should have_content(restaurant.name) }

            it "should have correct start dates" do
              expect(page.all("#shifts__start_day")[0].find('option[selected]').text).to eq batch[0].start.day.to_s
              expect(page.all("#shifts__start_day")[1].find('option[selected]').text).to eq batch[1].start.day.to_s
              expect(page.all("#shifts__start_day")[2].find('option[selected]').text).to eq batch[2].start.day.to_s
            end

            describe "executing batch edit" do
              before do  
                page.all("#shifts__start_hour")[0].select '6 AM'
                page.all("#shifts__start_hour")[1].select '7 AM'
                page.all("#shifts__start_hour")[2].select '8 AM'
                click_button 'Save changes'
              end

              describe "after editing" do

                it "should have correct URI" do
                  expect(current_path).to eq "/shifts/"
                end

                describe "page contents" do
                  before { filter_shifts_by_time_inclusively }

                  it "should show new values of edited shifts" do
                    expect(page.find("#row_1_col_2").text).to include '6:00AM'
                    expect(page.find("#row_2_col_2").text).to include '7:00AM'
                    expect(page.find("#row_3_col_2").text).to include '8:00AM'
                  end
                end
              end
            end
          end
        end
      end 
    end

    describe "BATCH ASSIGN" do
      before do
        other_rider
        batch.each(&:save)
        batch.each { |s| s.assignment.update(rider_id: rider.id, status: :confirmed) }
      end

      describe "from SHIFTS INDEX" do
        before do
          visit shifts_path
          filter_shifts_by_time_inclusively
          page.within("#row_1"){ find("#ids_").set true }
          page.within("#row_2"){ find("#ids_").set true }
          page.within("#row_3"){ find("#ids_").set true }        
        end

        describe "with standard batch edit" do
          before { click_button 'Batch Assign', match: :first }
          
          describe "batch edit assignment page" do 
            it "should have correct URI" do 
              check_batch_assign_uri
            end
            
            it { should have_h1 'Batch Assign Shifts' }
            it { should have_content(restaurant.name) }

            it "should have correct assignment values" do

              expect(page.within("#shift_#{batch[0].id}_wrapper"){ find("#assignments__rider_id").find("option[selected]").text }).to eq rider.name
              expect(page.within("#shift_#{batch[1].id}_wrapper"){ find("#assignments__rider_id").find("option[selected]").text }).to eq rider.name
              expect(page.within("#shift_#{batch[2].id}_wrapper"){ find("#assignments__rider_id").find("option[selected]").text }).to eq rider.name

              expect(page.within("#shift_#{batch[0].id}_wrapper"){ find("#assignments__status").find("option[selected]").text }).to eq 'Confirmed'
              expect(page.within("#shift_#{batch[1].id}_wrapper"){ find("#assignments__status").find("option[selected]").text }).to eq 'Confirmed'
              expect(page.within("#shift_#{batch[2].id}_wrapper"){ find("#assignments__status").find("option[selected]").text }).to eq 'Confirmed'
            end
          end

          describe "executing batch assignment edit" do
            before do  
              page.within("#shift_#{batch[0].id}_wrapper") { find("#assignments__rider_id").select other_rider.name }
              page.within("#shift_#{batch[1].id}_wrapper") { find("#assignments__rider_id").select other_rider.name }
              page.within("#shift_#{batch[2].id}_wrapper") { find("#assignments__rider_id").select other_rider.name }

              page.within("#shift_#{batch[0].id}_wrapper") { find("#assignments__status").select 'Proposed' }
              page.within("#shift_#{batch[1].id}_wrapper") { find("#assignments__status").select 'Proposed' }
              page.within("#shift_#{batch[2].id}_wrapper") { find("#assignments__status").select 'Proposed' }

              click_button 'Save changes'
            end

            describe "after editing" do
              
              it "should redirect to the correct page" do
                expect(current_path).to eq "/shifts/"
              end

              describe "index page" do
                before { filter_shifts_by_time_inclusively }

                it "should show new values of edited shifts" do
                  expect(page.find("#row_1_col_3").text).to eq other_rider.name
                  expect(page.find("#row_2_col_3").text).to eq other_rider.name
                  expect(page.find("#row_3_col_3").text).to eq other_rider.name

                  expect(page.find("#row_1_col_4").text).to eq 'Proposed'
                  expect(page.find("#row_2_col_4").text).to eq 'Proposed'
                  expect(page.find("#row_3_col_4").text).to eq 'Proposed'

                end
              end              
            end
          end  
        end

        describe "with uniform batch edit" do
          before { click_button 'Uniform Assign', match: :first }

          describe "uniform batch edit page" do
            it "should have correct URI" do
              check_uniform_assign_uri
            end

            it { should have_h1 'Uniform Assign Shifts' }
            it { should have_content restaurant.name }

            it "should have correct form values" do
              expect(page.within("#assignment_wrapper"){ find("#assignment_rider_id").has_css?("option[selected]") } ).to eq false
              expect(page.within("#assignment_wrapper"){ find("#assignment_status").find("option[selected]").text }).to eq 'Proposed'
            end
          end

          describe "executing batch edit" do
            before do
              page.within("#assignment_wrapper"){ find("#assignment_rider_id").select other_rider.name }
              page.within("#assignment_wrapper"){ find("#assignment_status").select 'Cancelled (Rider)' }
              click_button 'Save changes'
            end

            describe "after editing" do
              it "should redirect to the correct page" do
                expect(current_path).to eq "/shifts/"
              end

              describe "index page" do
                before { filter_shifts_by_time_inclusively }

                it "should show new values for re-assigned shifts" do
                  expect(page.find("#row_1_col_3").text).to eq other_rider.name
                  expect(page.find("#row_2_col_3").text).to eq other_rider.name
                  expect(page.find("#row_3_col_3").text).to eq other_rider.name

                  expect(page.find("#row_1_col_4").text).to eq 'Cancelled (Rider)'
                  expect(page.find("#row_2_col_4").text).to eq 'Cancelled (Rider)'
                  expect(page.find("#row_3_col_4").text).to eq 'Cancelled (Rider)'
                end
              end
            end
          end
        end
      end

      describe "from GRID" do
        before do 
          restaurant.mini_contact.update(name: 'A'*10)
          visit shift_grid_path 
          filter_grid_for_jan_2014
        end

        describe "page contents" do

          describe "batch edit form" do

            it { should have_button 'Batch Assign' }
            it "should have correct form action" do
              expect(page.find("form.batch")['action']).to eq '/shift/batch_edit'
            end              
          end

          describe "grid rows" do

            it "should have correct cells in first row" do
              expect(page.find("#row_1_col_1").text).to eq 'A'*10
              expect(page.find("#row_1_col_6").text).to eq rider.short_name + " [c]"
              expect(page.find("#row_1_col_8").text).to eq rider.short_name + " [c]"
              expect(page.find("#row_1_col_10").text).to eq rider.short_name + " [c]"
            end              
          end
        end

        describe "standard batch assignment" do
          before do
            page.within("#row_1_col_6"){ find("#ids_").set true }
            page.within("#row_1_col_8"){ find("#ids_").set true }
            page.within("#row_1_col_10"){ find("#ids_").set true }
            click_button 'Batch Assign'
          end

          describe "batch assign page" do
            it "should have correct URI" do
              check_batch_assign_uri
            end

            it "should have correct assignment values" do
              check_batch_assign_select_values
            end            
          end

          describe "executing batch assignment" do
            before do 
              page.all("#assignments__rider_id")[0].select other_rider.name
              page.all("#assignments__rider_id")[1].select other_rider.name
              page.all("#assignments__rider_id")[2].select other_rider.name

              page.all("#assignments__status")[0].select 'Proposed'
              page.all("#assignments__status")[1].select 'Proposed'
              page.all("#assignments__status")[2].select 'Proposed'

              click_button 'Save changes'
            end

            describe "after editing" do

              it "should redirect to the correct page" do
                expect(current_path).to eq "/grid/shifts"
              end

              describe "page contents" do
                before { filter_grid_for_jan_2014 }

                it "should have new assignment values" do
                  expect(page.find("#row_1_col_6").text).to eq other_rider.short_name + " [p]" 
                  expect(page.find("#row_1_col_8").text).to eq other_rider.short_name + " [p]"
                  expect(page.find("#row_1_col_10").text).to eq other_rider.short_name + " [p]" 
                end
              end
            end
          end
        end

        describe "uniform batch assignment" do
          before do
            page.within("#row_1_col_6"){ find("#ids_").set true }
            page.within("#row_1_col_8"){ find("#ids_").set true }
            page.within("#row_1_col_10"){ find("#ids_").set true }
            click_button 'Uniform Assign'            
          end

          describe "uniform assign page" do
            
            it "should have correct uri" do
              check_uniform_assign_uri
            end

            it { should have_h1 'Uniform Assign Shifts' }
            it { should have_content restaurant.name }

            it "should have correct form values" do
              expect(page.within("#assignment_wrapper"){ find("#assignment_rider_id").has_css?("option[selected]") } ).to eq false
              expect(page.within("#assignment_wrapper"){ find("#assignment_status").find("option[selected]").text }).to eq 'Proposed'
            end
          end

          describe "executing batch edit" do
            before do
              page.within("#assignment_wrapper"){ find("#assignment_rider_id").select other_rider.name }
              page.within("#assignment_wrapper"){ find("#assignment_status").select 'Cancelled (Rider)' }
              click_button 'Save changes'
            end

            describe "after editing" do
              it "should redirect to the correct page" do
                expect(current_path).to eq "/grid/shifts"
              end

              describe "index page" do
                before { filter_grid_for_jan_2014 }

                it "should show new values for re-assigned shifts" do
                  expect(page.find("#row_1_col_6").text).to eq other_rider.short_name + " [xf]" 
                  expect(page.find("#row_1_col_8").text).to eq other_rider.short_name + " [xf]"
                  expect(page.find("#row_1_col_10").text).to eq other_rider.short_name + " [xf]" 

                end
              end
            end
          end
        end
      end 
    end  
  end
end



