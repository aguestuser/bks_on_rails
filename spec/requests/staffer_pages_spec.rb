require 'spec_helper'
include CustomMatchers
include RequestSpecMacros

describe "Staffer Pages" do
  let(:staffer) { FactoryGirl.build(:staffer) }
  let(:contact) { staffer.account.contact }
  let(:fields) { ['Name', 'Title', 'Phone', 'Email'] }
  subject { page }

  describe "Staffers#new" do
    before do 
      visit new_staffer_path 
      fill_in 'Name',     with: contact.name
      fill_in 'Title',    with: contact.title
      fill_in 'Phone',    with: contact.phone
      fill_in 'Email',    with: contact.email
      fill_in 'Password', with: staffer.account.password
      fill_in 'Password confirmation', with: staffer.account.password
    end    
    
    let(:submit) { 'Create Staffer' }

    it "should have expected fields" do
      check_fields fields
    end

    it "should create a new Staffer" do
      expect { click_button submit }.to change(Staffer, :count).by(1)
    end

    it "should create a new Account" do
      expect { click_button submit }.to change(Account, :count).by(1)
    end

    it "should create a new Contact" do
      expect { click_button submit }.to change(Account, :count).by(1)
    end

    describe "after saving the staffer" do
      before { click_button submit }
      let(:saved_staffer) { Staffer.find(staffer.id) }     

      it { should have_title(contact.name) }
      it { should have_success_message("Profile created for #{contact.name}.") }
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
    before(:all) do
      3.times { FactoryGirl.create(:staffer) } 
      visit staffers_path
    end 
    after(:all) { Staffer.last(3).each { |s| s.destroy } }
    let(:names) { Staffer.last(3).map { |s| s.account.contact.name } }
    
    it "should contain names of last 3 staffers" do
      check_name_subheads names
    end
  end
end

