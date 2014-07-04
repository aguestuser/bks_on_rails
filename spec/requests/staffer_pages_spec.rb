require 'spec_helper'
include CustomMatchers

describe "Staffer Pages" do
  let(:staffer) { FactoryGirl.build(:staffer) }
  subject { page }


  describe "creating new Staffer" do
    before do 
      visit new_staffer_path 
      fill_in 'Name',     with: staffer.name
      fill_in 'Title',    with: staffer.title
      fill_in 'Phone',    with: staffer.contact_info.phone
      fill_in 'Email',    with: staffer.contact_info.email
    end    
    
    let(:submit) { 'Create staffer' }

    it "should create a new Staffer" do
      expect { click_button submit }.to change(Staffer, :count).by(1)
    end

    it "should create a new ContactInfo" do
      expect { click_button submit }.to change(ContactInfo, :count).by(1)
    end

    describe "after saving the staffer" do
      before { click_button submit }
      let(:saved_staffer) { Staffer.find_by_email(staffer.email) }     

      it { should have_title(saved_staffer.name) }
      it { should have_success_message("Profile created for #{saved_staffer.name}.") }
    end
  end

  describe "editing an existing Staffer" do
    before do 
      staffer.save
      visit edit_staffer_path(staffer)
    end

    describe "page" do
      it { should have_heading("Edit #{staffer.name}'s Profile") }
    end

    describe "with invalid input" do
      before do 
        fill_in 'Name', with: '' 
        click_button 'Save changes'
      end
      it { should have_an_error_message }
    end

    describe "with valid input" do
      let(:new_name) { 'Horrible Person' }
      let(:new_email) { 'horribleperson@example.com' }
      before do
        fill_in 'Name',   with: new_name
        fill_in 'Email',  with: new_email
        click_button "Save changes"
      end

      it { should have_heading(new_name) }
      it { should have_success_message("#{new_name}'s profile has been updated") }
      specify { expect(staffer.reload.name).to eq new_name }
      specify { expect(staffer.reload.email).to eq new_email }

    end

  end
end