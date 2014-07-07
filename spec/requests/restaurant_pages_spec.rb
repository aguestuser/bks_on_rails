require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RestaurantMacros # /spec/support/restaurant_macros.rb

describe "Restaurant Pages" do
  let(:restaurant) { FactoryGirl.build(:restaurant) }
  subject { page }

  describe "creating new Restaurant" do
    before do
      visit new_restaurant_path
      fill_in_new_restaurant_form
    end
    let(:submit) { 'Create restaurant' }

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