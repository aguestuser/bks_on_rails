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
end