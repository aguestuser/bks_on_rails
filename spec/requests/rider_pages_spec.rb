require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RiderPageMacros # /spec/support/restaurant_macros.rb
include RequestSpecMacros # /spec/support/request_spec_macros.rb

describe "Rider Pages" do
  let!(:rider) { FactoryGirl.build(:rider) }
  let!(:account) { rider.account }
  let(:contact) { account.contact }
  let(:location) { rider.location }
  let(:qualification_set) { rider.qualification_set }
  let(:skill_set) { rider.qualification_set }
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
      before(:all) { 3.times { FactoryGirl.create(:rider) } }
      after(:all) { Rider.last(3).each { |r| r.destroy } }
      before(:each) { visit riders_path }
      let(:names) { Rider.last(3).map { |r| r.account.contact.name } }

      it "should contain names of last 3 riders" do
        check_name_subheads names
      end

      it { should have_h1('Riders') }
      it { should have_link('Create Rider', href: new_rider_path) }
    end
  end
end