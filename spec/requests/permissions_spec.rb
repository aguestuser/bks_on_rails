require 'spec_helper'
require 'cancan/matchers'
include RequestSpecMacros

describe "Authentication" do
  subject { page }
  let!(:staffer) { FactoryGirl.create(:staffer) }
  let(:rider) { FactoryGirl.create(:rider) }
  let(:other_rider) { FactoryGirl.create(:rider) }
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let(:manager) { restaurant.managers.first }
  let(:shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }
  let(:other_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: other_restaurant) }

  describe "sign in" do

    before { visit sign_in_path }

    describe "page contents" do
      it { should have_title('Sign in') }
      it { should have_h1('Sign in') }      
    end

    describe "form submission" do
      
      describe "with invalid input" do
        before { click_button 'Sign in' }
        it { should have_button('Sign in') }
        it { should have_an_error_message }
        # it { should_not have_signed_in_nav_links_for_user(:staffer) }
      end

      describe "with valid input" do
        before { mock_sign_in staffer }
        let(:contact) { staffer.account.contact }

        it { should have_title(contact.name) }
      end
    end
  end

  describe "permissions" do
    
    let(:nav_links) { get_nav_links }
    let(:paths) { get_paths }


    describe "as Rando" do
      
      describe "nav links" do

        before { visit root_path }

        it "should not have nav links" do
          check_no_links nav_links
        end
        # should not see any nav links, only "Sign in"
      end

      describe "trying to view pages" do
        it "should be redirected to sign in page" do
          check_sign_in_redirect paths          
        end
        # should not be able to make any edits through http requests
      end
    end

    describe "as Staffer" do
      
      before { mock_sign_in staffer }

      describe "root path" do
        before { visit root_path }

        it { should have_h1 staffer.account.contact.name }
      end

      it "should have appropriate nav links" do
        check_links nav_links
      end

      describe "accessing controller actions" do
        subject(:ability) { Ability.new(staffer.account) }
        it { should be_able_to :manage, :all }
      end
    end

    describe "as Manager" do

      before { mock_sign_in manager }
      let(:manager_name) { manager.account.contact.name }
      let(:own_restaurant) { restaurant }
      let(:other_manager) { restaurant.managers[1] }
      let(:other_restaurant) { FactoryGirl.create(:restaurant) }
      let(:other_restaurant_manager) { other_restaurant.managers.first }

      it "should have appropriate nav links" do
        check_links ['Staffers', 'Account', 'Homepage', 'Settings', 'Sign out' ]
        check_no_links [ 'Riders', 'Restaurants', 'Shifts' ]
      end

      describe "profile page" do
        before { click_link 'Homepage' }
        it { should have_h1 manager_name }
      end

      describe "accessing controller actions" do
        
        subject(:ability) { Ability.new(manager.account) }

        describe "for Restaurants" do
          it { should_not be_able_to :create, Restaurant.new }
          it { should_not be_able_to :edit, other_restaurant  }
          it { should be_able_to :edit, own_restaurant }
          it { should_not be_able_to :read, other_restaurant }
          it { should be_able_to :read, own_restaurant }
          it { should_not be_able_to :destroy, own_restaurant }
          it { should_not be_able_to :destroy, other_restaurant }           
        end

        describe "for Managers" do
          it { should_not be_able_to :create, Manager.new }
          it { should_not be_able_to :edit, other_restaurant_manager }
          it { should_not be_able_to :edit, other_manager }
          it { should be_able_to :edit, manager }
          it { should_not be_able_to :read, other_restaurant_manager }
          it { should be_able_to :read, other_manager }
          it { should be_able_to :read, manager }
          it { should_not be_able_to :destroy, other_restaurant_manager}
          it { should_not be_able_to :destroy, other_manager }
          it { should_not be_able_to :destroy, manager }
        end

        describe "for Staffers" do
          it { should_not be_able_to :create, Staffer.new }
          it { should_not be_able_to :edit, staffer }
          it { should be_able_to :read, staffer }
          it { should_not be_able_to :destroy, staffer }
        end

        describe "for Riders" do
          #blocked actions: create, edit, read, destory
          it { should_not be_able_to :create, Rider.new }
          it { should_not be_able_to :edit, rider }
          it { should_not be_able_to :read, rider }
          it { should_not be_able_to :destroy, rider }
        end

        describe "for Shifts" do
          it { should_not be_able_to :create, Shift.new }
          it { should_not be_able_to :edit, shift }
          it { should_not be_able_to :edit, other_shift }
          it { should_not be_able_to :read, other_shift }
          it { should be_able_to :read, shift }
          it { should_not be_able_to :destroy, Shift.new }
        end
      end  

    end
    describe "as Rider" do

      before { mock_sign_in rider }

      it "should have appropriate nav links" do
        check_links [ 'Shifts', 'Staffers',  'Account', 'Homepage', 'Settings', 'Sign out'  ]
        check_no_links [ 'Restaurants' ]
      end

      describe "root path" do
        before { visit root_path }
        it { should have_h1 rider.account.contact.name }
      end

      describe "accessing controller actions" do
        subject(:ability) { Ability.new(rider.account) }

        describe "for Restaurants" do
          #blocked: all
          it { should_not be_able_to :create, Restaurant.new }
          it { should_not be_able_to :read, Restaurant.new }
          it { should_not be_able_to :update, Restaurant.new }
          it { should_not be_able_to :destroy, Restaurant.new }
        end

        describe "for Managers" do
          #blocked: all
          it { should_not be_able_to :create, Manager.new }
          it { should_not be_able_to :read, manager }
          it { should_not be_able_to :update, manager }
          it { should_not be_able_to :destroy, manager } 
        end

        describe "for Staffers" do
          it { should_not be_able_to :create, Staffer.new }
          it { should be_able_to :read, staffer }
          it { should_not be_able_to :update, staffer }
          it { should_not be_able_to :destroy, staffer }
        end

        describe "for Riders" do
          it { should_not be_able_to :create, Rider.new }
          it { should be_able_to :read, rider }
          it { should_not be_able_to :read, other_rider }
          it { should be_able_to :update, rider }
          it { should_not be_able_to :update, other_rider }
          it { should_not be_able_to :destroy, Rider.new }
        end

        describe "for Shifts" do
          it { should_not be_able_to :create, Shift.new }
          it { should_not be_able_to :read, Shift.new }
          it { should_not be_able_to :update, Shift.new }
          it { should_not be_able_to :destroy, Shift.new }          
        end
      end
    end
  end
end