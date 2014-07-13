require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RestaurantMacros # /spec/support/restaurant_macros.rb
include RequestSpecMacros

describe "Restaurant Pages" do
  let!(:restaurant) { FactoryGirl.build(:restaurant) }
  let!(:manger) { restaurant.managers.first }
  let!(:contact) { restaurant.mini_contact }
  let!(:work_spec) { restaurant.work_specification }
  let!(:rider_payment) { restaurant.rider_payment_info }
  let!(:agency_payment) { restaurant.agency_payment_info }
  let!(:location) { restaurant.location }
  # let(:form_edits) { form: { fields: ['Restaurant name', 'Name' ], values: [ 'Poop Palace', 'Sir Poopy Pants' ] } }
    
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
        it { should have_h3("Managers") }
        it { should have_h3("Rider Compensation") }
        it { should have_h3("Equipment") }
        it { should have_h3("Agency Compensation") }
      end
    end

    describe "Restaurants#index" do
      before(:all) do
        3.times { FactoryGirl.create(:restaurant) } 
      end 
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
      let(:new_form) { get_form_hash 'new' }

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

        before { fill_in_form new_form }
        let(:submit) { 'Create Restaurant' }

        it "should create a new Restaurant" do
          expect { click_button submit }.to change(Restaurant, :count).by(1)
        end

        it "should create a new MiniContact" do
          expect { click_button submit }.to change(MiniContact, :count).by(2)
        end

        it "should create a new Location" do
          expect { click_button submit }.to change(Location, :count).by(2)
        end

        it "should create a new Manager" do
          expect { click_button submit }.to change(Manager, :count).by(1)
        end

        it "should create a new Contact" do
          expect { click_button submit }.to change(Contact, :count).by(1)
        end

        it "should create a new RiderPaymentInfo" do
          expect { click_button submit }.to change(RiderPaymentInfo, :count).by(1)
        end

        it "should create a new WorkSpecification" do
          expect { click_button submit }.to change(WorkSpecification, :count).by(1)
        end

        it "should create a new AgencyPaymentInfo" do
          expect { click_button submit }.to change(AgencyPaymentInfo, :count).by(1)
        end
      end  
    end

    describe "Restaurants#edit" do
      before do
        restaurant.save
        visit edit_restaurant_path(restaurant)
      end
      let(:save) { "Save Changes" }

      describe "page contents" do
        it "should have all expected labels" do
          check_form_labels form
        end
      end

      describe "with invalid input" do
        before do 
          fill_in_form invalid_edits
          click_button save
        end

        it { should have_an_error_message }
      end

      describe "with valid input" do
        before { fill_in_form fields: {'Restaurant name' => 'Poop Palace' } }

        it { should have_h1('Restaurants') }
        it { should have_success_message("Poop Palace's profile has been updated.") }
        specify { expect(restaurant.reload.mini_contact.name).to eq 'Poop Palace' }
      end
    end

  end
  


end