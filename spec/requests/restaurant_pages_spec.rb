require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RestaurantPageMacros # /spec/support/restaurant_macros.rb
include RequestSpecMacros # /spec/support/request_spec_macros.rb

describe "Restaurant Pages" do
  let!(:restaurant) { FactoryGirl.build(:restaurant) }
  let!(:manger) { restaurant.managers.first }
  let!(:contact) { restaurant.mini_contact }
  let!(:work_spec) { restaurant.work_specification }
  let!(:rider_payment) { restaurant.rider_payment_info }
  let!(:agency_payment) { restaurant.agency_payment_info }
  let!(:location) { restaurant.location }
  # let(:form_edits) { form: { fields: ['Restaurant name', 'Name' ], values: [ 'Poop Palace', 'Sir Poopy Pants' ] } }
  let(:staffer) { FactoryGirl.create(:staffer) }

  before { mock_sign_in staffer }

  subject { page }

  describe "display pages" do
  
    describe "Restaurants#show" do
      before do
        restaurant.save
        visit restaurant_path(restaurant)
      end

      describe "page contents" do
        it { should have_h1("#{contact.name}") }
        it { should have_h3("Shifts") }
        it { should have_h3("Contact Info") }
        it { should have_content('Address:') }
        it { should have_h3("Managers") }
        it { should have_h3("Rider Compensation") }
        it { should have_h3("Equipment") }
        it { should have_h3("Agency Compensation") }
      end
    end

    describe "Restaurants#index" do
      before(:all) { 3.times { FactoryGirl.create(:restaurant) } }
      after(:all) { Restaurant.last(3).each { |s| s.destroy } }
      before(:each) { visit restaurants_path }
      let(:names) { Restaurant.last(3).map { |s| s.mini_contact.name } }
      
      it "should contain names of last 3 staffers" do
        check_name_subheads names
      end 
      it { should have_h1('Restaurants') }
      it { should have_link('Create new restaurant', href: new_restaurant_path) }   
    end
  end

  describe "form pages" do

    describe "Restaurants#new" do
      
      before { visit new_restaurant_path }
      let(:new_form) { get_restaurant_form_hash 'new' }
      let(:submit) { 'Create Restaurant' }

      describe "page contents" do
        it { should_not have_h3('Status') }
        it { should have_h3('Contact Info') }
        it { should have_selector('label', text: 'Street address') }
        it { should have_h3('Managers') }
        it { should have_h3('Rider Compensation') }
        it { should have_h3('Working Conditions') }
        it { should have_h3('Equipment') }
        it { should have_h3('Agency Compensation') }
        # it "should have expected form labels" do
        #   check_form_labels form
        # end
      end

      describe "form submission" do

        describe "with invalid input" do
          before { click_button submit }
          it { should have_an_error_message }
        end

        describe "with valid input" do

          let!(:old_restaurant_count) { Restaurant.count }
          let!(:old_mini_contacts_count) { MiniContact.count }
          let!(:old_locations_count) { Location.count }
          let!(:old_managers_count) { Manager.count }
          let!(:old_contacts_count) { Contact.count }
          let!(:old_rider_payments_count) { RiderPaymentInfo.count }
          let!(:old_work_specifications_count) { WorkSpecification.count }
          let!(:old_equipment_sets_count) { EquipmentSet.count }
          let!(:old_agency_payments_count) { AgencyPaymentInfo.count }

          before do 
            fill_in_form new_form
            click_button submit 
          end
          
          it "should create new instances of associated models" do
            expect( Restaurant.count - old_restaurant_count ).to eq 1
            expect( MiniContact.count - old_mini_contacts_count ).to eq 1
            expect( Location.count - old_locations_count ).to eq 1
            expect( Manager.count - old_managers_count ).to eq 1
            expect( Contact.count - old_contacts_count ).to eq 1
            expect( RiderPaymentInfo.count - old_rider_payments_count ).to eq 1
            expect( WorkSpecification.count - old_work_specifications_count ).to eq 1
            expect( EquipmentSet.count - old_equipment_sets_count ).to eq 1
            expect( AgencyPaymentInfo.count - old_agency_payments_count ).to eq 1
          end        

          describe "after successful submission" do
            # let(:url) { URI.parse(current_url) }

            # specify { expect(url).to eq restaurant_path(restaurant.reload.id) }
            it { should have_success_message("Profile created for #{contact.name}") }
            it { should have_h1(contact.name) }        
          end      
        end
      end  
    end

    describe "Restaurants#edit" do
      before do
        restaurant.save
        visit edit_restaurant_path(restaurant)
      end
      let(:save) { "Save Changes" }
      let(:edit_form) { get_restaurant_form_hash 'edit' }

      describe "page contents" do
        it { should have_h3('Status') }
        it { should have_h3('Contact Info') }
        it { should have_selector('label', text: 'Street address') }
        it { should have_h3('Managers') }
        it { should have_h3('Rider Compensation') }
        it { should have_h3('Working Conditions') }
        it { should have_h3('Equipment') }
        it { should have_h3('Agency Compensation') }
      end

      describe "with invalid input" do
        before do 
          fill_in_form fields: { 'Restaurant name' => '' }, selects: {}, checkboxes: []
          click_button save
        end

        it { should have_an_error_message }
      end

      describe "with valid input" do
        before do 
          fill_in_form edit_form
          click_button save
        end

        it { should have_h1('Restaurants') }
        it { should have_success_message("Poop Palace's profile has been updated") }
        specify { expect(restaurant.mini_contact.reload.name).to eq 'Poop Palace' }
        specify { expect(restaurant.reload.location.reload.borough.text).to eq 'Staten Island' }
        specify { expect(restaurant.reload.equipment_set.reload.bike).to eq false  }
      end
    end
  end
end