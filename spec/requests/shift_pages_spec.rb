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

        before { visit shifts_path }

        describe "page contents" do

          it { should have_h1('Shifts')}
          it { should have_link('Create shift') }
          it { should have_content('Restaurant') }
          it { should have_link('Action') }
          it { should have_content(restaurant.mini_contact.name) }
          it { should have_content(other_restaurant.mini_contact.name) }          
        end

        describe "pagination" do
          before do
            shifts
            visit shifts_path
          end

          it { should_not have_content format_start(shifts[30].start) }

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