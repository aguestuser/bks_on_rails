require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RiderPageMacros # /spec/support/restaurant_macros.rb
include RequestSpecMacros # /spec/support/request_spec_macros.rb

describe "Rider Pages" do
  load_rider_resources
  let(:staffer) { FactoryGirl.create(:staffer) }
  before { mock_sign_in staffer }
  subject { page }

  describe "display pages" do
    
    describe "Riders#show" do
      before do
        rider.save
        visit rider_path(rider)
      end

      describe "page contents" do
        it { should have_h1("#{contact.name}") }
        it { should have_h3("Contact Info") }
        it { should have_content('Address:') }
        it { should have_h3("Rating") }
        it { should have_h3("Qualifications") }
        it { should have_h3("Skills") }
        it { should have_h3("Equipment") }
      end
    end    
    
    describe "Riders#index" do
      before do
        riders.each_with_index{ |rider, i| rider.contact.update(name: "AAAAA"*i) }
        visit riders_path
      end

      let(:names){ riders.map{ |r| r.contact.name } }

      it "should contain names of last 3 riders" do
        check_name_subheads names
      end

      it { should have_h1('Riders') }
      it { should have_link('Create Rider', href: new_rider_path) }
    end
  end

  describe "form pages" do

    describe "Riders#new" do
      
      before { visit new_rider_path }
      let(:new_form) { get_rider_form_hash 'new' }
      let(:submit) { 'Create Rider' }

      describe "page contents" do
        it { should have_h1("Create Rider") }
        it { should have_h3("Account Info") }
        it { should have_label('Password') }
        it { should have_label('Password confirmation') }   
        it { should have_h3("Contact Info") }
        it { should have_label('Street address') }
        it { should have_h3("Rating") }
        it { should have_h3("Qualifications") }
        it { should have_h3("Skills") }
        it { should have_h3("Equipment") }
      end

      describe "form submission" do       
        let(:models) { [ Rider, Account, Contact, Location, EquipmentSet, QualificationSet, SkillSet, RiderRating ] }
        let!(:old_counts) { count_models models }       

        describe "with invalid input" do

          before { click_button submit }
          it { should have_an_error_message }
        end

        describe "with valid input" do

          before do
            fill_in_form new_form
            click_button submit
          end

          describe "after submission" do

            let!(:new_counts) { count_models models }
            
            it "should create new instances of associated models" do
              expect( model_counts_incremented? old_counts, new_counts, 1 ).to eq true
            end          
            it { should have_success_message("Profile created for #{contact.name}") }
            it { should have_h1 rider.name }
          end
        end
      end
    end
  end

  describe "Terms of Employment form" do
    let!(:toe_consent_count){ ToeConsent.count }
    let!(:this_rider){ FactoryGirl.create(:rider) }
    
    before do
      visit new_rider_toe_consent_path this_rider
      click_button 'I Agree'
    end

    it "creates a new ToeConsent" do
      expect(ToeConsent.count).to eq toe_consent_count + 1
      expect(rider.toe_consent.ip).to eq "127.0.0.1"
      expect(rider.toe_consent.created_at.beginning_of_day).to eq Time.zone.now.beginning_of_day
    end

    describe "second submission" do

      let!(:new_count){ ToeConsent.count }

      before do
        visit new_rider_toe_consent_path this_rider
        click_button 'I Agree'
      end

      it "doesn't create a new ToeConsent" do
        expect(ToeConsent.count).to eq new_count
      end
    end

  end # "Terms of Employment form"

  describe "active/inactive scoping" do
    
    let(:shift) do
      FactoryGirl.create(
        :shift,
        :with_restaurant,
        restaurant: FactoryGirl.create(:restaurant),
        start: Time.zone.local(2014,1,7,12),
        :end => Time.zone.local(2014,1,7,18)
      )
    end
    before { 
      riders
      shift.rider.destroy
      shift.unassign
    } 
    
    describe "with last of 3 riders inactive" do
      before { riders.last.update(active: false) }
      
      describe "in shift index multiselect" do
        before { visit shifts_path }

        it "should only include active riders" do
          riders.first(2).each do |rider| 
            expect( page.find("#filter_riders").text ).to include rider.name 
          end
          expect( page.find("#filter_riders").text ).not_to include riders.last.name
        end  
      end

      describe "in assignment edit dropdown" do
        before { visit edit_shift_assignment_path( shift, shift.assignment ) }

        it "should only include active riders" do
          riders.first(2).each do |rider|
            expect(page.find( "#assignment_rider_id" ).text ).to include rider.name
          end
          expect(page.find( "#assignment_rider_id" ).text).not_to include riders.last.name
        end
      end
      
      describe "in availability grid" do
        before do
          visit availability_grid_path
          fill_in "filter[start]", with: "January 6, 2014"
          click_button 'Filter'
        end

        it "should only include active riders" do
          riders.first(2).each do |rider|
            expect(page.all( ".y_axis_label" ).map(&:text)).to include rider.name
          end
          expect(page.all( ".y_axis_label" ).map(&:text)).not_to include riders.last.name
        end  
      end
    
    end

    describe "Edit Rider Statuses Page" do
      before { visit edit_statuses_riders_path }

      describe "contents: " do
        it { should have_h1 'Edit Rider Statuses' }

        it "lists 3 riders with active box checked" do
          riders.each_with_index do |rider, i|
            expect(page).to have_content(rider.name)
            expect(page.find("#riders_1_active")).to be_checked
          end
        end      
      end # "contents"

      describe "commiting edit" do
        before do 
          uncheck "riders[1][active]"
          click_button 'Submit', match: :first
        end

        it "makes the last rider inactive" do
          expect(riders[1].reload.active).to eq false
        end
      end
    end # "Set Rider Status Page"
  end
end

