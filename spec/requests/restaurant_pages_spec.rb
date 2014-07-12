require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RestaurantMacros # /spec/support/restaurant_macros.rb

describe "Restaurant Pages" do
  let(:restaurant) { FactoryGirl.build(:restaurant) }
  let(:contact) { restaurant.mini_contact }
  let(:location) { restaurant.location }
  subject { page }

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

  describe "Restaurants#new" do
    before do
      visit new_restaurant_path
      fill_in_new_restaurant_form
    end
    let(:submit) { 'Create Restaurant' }

    it "should create a new Restaurant" do
      expect { click_button submit }.to change(Restaurant, :count).by(1)
    end

    it "should create 2 new ContactInfo" do
      expect { click_button submit }.to change(ContactInfo, :count).by(2)
    end

    it "should create a new Manager" do
      expect { click_button submit }.to change(Manager, :count).by(1)
    end

    it "should create a new WorkArrangement" do
      expect { click_button submit }.to change(WorkArrangement, :count).by(1)
    end
  end
end