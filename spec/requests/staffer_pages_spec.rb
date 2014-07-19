require 'spec_helper'
include CustomMatchers
include RequestSpecMacros

describe "Staffer Pages" do
  let(:admin) { FactoryGirl.create(:staffer) }
  let(:staffer) { FactoryGirl.build(:staffer) }
  let(:contact) { staffer.account.contact }
  let(:fields) { ['Name', 'Title', 'Phone', 'Email'] }

  before { mock_sign_in admin }

  subject { page }

  describe "Staffers#new" do

    before { visit new_staffer_path }

    describe "page contents" do
      
      it { should have_h1 'Create Staffer' }
      it "should have expected fields" do
        check_fields fields
      end      
    end

    describe "form submission" do
      
      let(:submit) { 'Create Staffer' }
      let(:models) { [ Staffer, Account, Contact ] }
      let!(:old_counts) { count_models models }

      describe "with invalid input" do
        before  {click_button submit}
        it { should have_an_error_message }
      end

      describe "with valid input" do
        before do 
          visit new_staffer_path 
          fill_in 'Name',     with: contact.name
          fill_in 'Title',    with: contact.title
          fill_in 'Phone',    with: contact.phone
          fill_in 'Email',    with: contact.email
          fill_in 'Password', with: staffer.account.password
          fill_in 'Password confirmation', with: staffer.account.password
          click_button submit
        end

        describe "after submission" do
          let(:new_counts){ count_models models }

          it "should create new intances of appropriate models" do
            expect( model_counts_incremented? old_counts, new_counts ).to eq true
          end
          it { should have_title(contact.name) }
          it { should have_success_message("Profile created for #{contact.name}.") }

          describe "logging out admin" do

            before { click_link 'Sign out' }
            it { should have_link('Sign in') }

            describe "logging in new staffer" do

              before { mock_sign_in staffer }

              it { should_not have_an_error_message }
              it { should have_h1 staffer.account.contact.name }
            end
          end
        end    
      end
    end
  end

  describe "Staffers#show" do
    before do 
      staffer.save
      visit staffer_path(staffer)
    end

    describe "page contents" do
      it { should have_h1("#{contact.name}") }
      it { should have_h3("Contact Info") }
      it { should have_link('Edit') }
      it { should have_link('Delete') }
      it { should have_content("#{contact.phone}")}
    end

    describe "editing Staffer profile" do
      before { click_link "Edit" }

      describe "page" do
        it { should have_h1("Edit #{contact.name}'s Profile") }
      end
    end
  end

  describe "Staffers#destory" do
    before do
      staffer.save
      visit staffer_path(staffer)
    end

    describe "deleting Staffer" do
      it "should reduce Staffer count by 1" do
        expect { click_link "Delete" }.to change(Staffer, :count).by(-1)
      end
      # it "should reduce Account count by 1" do
      #   expect { click_link "Delete" }.to change(Account, :count).by(-1)
      # end
      it "should reduce ContactInfo count by 1" do
        expect { click_link "Delete" }.to change(Contact, :count).by(-1)
      end
    end
  end

  describe "Staffers#edit" do
    before do
      staffer.save
      visit edit_staffer_path(staffer)
    end

    describe "page contents" do
      specify { find_field('Phone').value.should eq contact.phone }
      specify { find_field('Email').value.should eq contact.email }
    end

    describe "with invalid input" do
      before do 
        fill_in 'Name', with: '' 
        click_button "Save Changes"
      end
      it { should have_an_error_message }
    end

    describe "with valid input" do
      let(:new_name) { 'Horrible Person' }
      let(:new_email) { 'horribleperson@example.com' }
      before do
        fill_in 'Name',   with: new_name
        fill_in 'Email',  with: new_email
        fill_in 'Password', with: staffer.account.password
        fill_in 'Password confirmation', with: staffer.account.password
        click_button "Save Changes"
      end

      it { should have_h1(new_name) }
      it { should have_success_message("#{new_name}'s profile has been updated.") }
      specify { expect(staffer.reload.account.contact.name).to eq new_name }
      specify { expect(staffer.reload.account.contact.email).to eq new_email }
    end  
  end

  describe "Staffers#index" do
    before(:all) { 3.times { FactoryGirl.create(:staffer) }  }
    after(:all) { Staffer.last(3).each { |s| s.destroy } }
    before(:each) { visit staffers_path }
    let(:names) { Staffer.last(3).map { |s| s.account.contact.name } }
    
    it "should contain names of last 3 staffers" do
      check_name_subheads names
    end
  end
end

