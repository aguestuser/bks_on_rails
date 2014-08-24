require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RiderPageMacros # /spec/support/restaurant_macros.rb
include RequestSpecMacros # /spec/support/request_spec_macros.rb

describe "Rider Pages" do
  let!(:rider) { FactoryGirl.build(:rider) }
  let(:riders){ 3.times.map{ FactoryGirl.create(:rider) } }
  let!(:account) { rider.account }
  let(:contact) { rider.contact }
  let(:location) { rider.location }
  let(:qualifications) { rider.qualification_set }
  let(:skills) { rider.qualification_set }
  let(:rating) { rider.rider_rating }

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
              expect( model_counts_incremented? old_counts, new_counts ).to eq true
            end          
            it { should have_success_message("Profile created for #{contact.name}") }
            it { should have_h1("Riders") }
          end
        end
      end
    end
  end
end

