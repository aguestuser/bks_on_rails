require 'spec_helper'
include RequestSpecMacros

describe "Authentication" do
  subject { page }
  let(:staffer) { FactoryGirl.create(:staffer) }
  let(:rider) { FactoryGirl.create(:rider) }
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let(:manager) { restaurant.managers.first }

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

  describe "authorization" do
    
    let(:nav_links) { get_nav_links }
    let(:paths) { get_paths }


    describe "as Rando" do
      
      describe "nav links" do

        before { visit root_path }

        it "should not have nav links" do
          check_no_nav_links nav_links
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

      describe "default page" do
        it { should have_h1 staffer.account.contact.name }
      end

      describe "Homepage" do
        before { click_link 'Homepage' }

        it { should have_h1 staffer.account.contact.name }
      end

      describe "root path" do
        before { visit root_path }

        it { should have_h1 staffer.account.contact.name }
      end

      describe "nav links" do
        #should see all nav links (Restaurants, Riders, Staff, Account > Homepage / Settings / Manual / Sign out )
      end

      describe "profile page" do
        before { click_link 'Home' }
        #should see profile page with own info
      end

      describe "accessing Restaurants" do
        before { click_link 'Restaurants' }
        #should be able to access restaurants index
        #should be able to edit a restaurant
      end

      describe "accessing Riders" do
        before { click_link 'Riders' }
        # should be able to access Riders index
        # should be able to edit Rider
      end

      describe "accessing Staffers" do
        before { click_link 'Staffers' }
        # should be able to access Staffers index
        # should be able to 
      end

      describe "accessing Shifts" do
        before { click_link 'Shifts' }
        # should be able to access Shifts index
        # should be able to access list of shifts for several restaurants
      end
    end

    describe "as Manager" do
      let(:manager_name) { manager.account.contact.name }
      describe "nav links" do
        it "should have appropriate nav links" do
          check_links ['Account', 'Homepage', 'Settings', 'Sign out', 'Staffers']
          check_no_links ['Riders', 'Restaurants', 'Shifts']
        end
      end

      describe "profile page" do
        before { click_link 'Homepage' }
        #should see profile page with own info
        it { should have_h1 manager_name }
      end

      describe "accessing Restaurants" do
        # blocked actions: new/create, edit/update(other restaurant), show(other restaurant), index, destroy
        # permitted actions: edit/update (own restaurant), show (own restaurant)

        let(:own_restaurant) { restaurant }
        let(:other_restaurant) { FactoryGirl.create(:restaurant) }


        it "should not be able to access blocked paths" do
          check_blocked_paths manager,  [  
                                          new_restaurants_path, #new
                                          edit_restaurant_path other_restaurant, #edit
                                          restaurant_path other_restaurant, #show
                                          restaurants_path, #index
                                        ]
        end

        it "should be able to access permitted paths" do
          check_permitted_paths manager,  [
                                            edit_restaurant_path own_restaurant, #edit
                                            restaurant_path own_restaurant, #show
                                          ]
        end
      end


      describe "accessing Riders" do
        # blocked actions: new/create, edit/update, show, index
        # permitted actions: NONE
        it "should not be able to access blocked paths" do
          check_blocked_paths manager, [
                                         new_rider_path, #new
                                         edit_rider_path rider, #edit
                                         rider_path rider, #show
                                         riders_path #index
                                       ]
        end
      end

      describe "accessing Staffers" do
        # blocked paths: new/create, edit/update
        # permitted paths: view, index
        it "should not be able to access blocked paths" do
          check_blocked_paths manager,  [
                                          new_staffer_path, #new
                                          edit_staffer_path #edit  
                                        ]
        end

        it "should be able to access permitted paths" do
          check_permitted_paths manager,  [
                                            staffer_path staffer, #show
                                            staffers_path #index
                                          ]
        end
      end

      describe "accessing Shifts" do
        let(:own_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurant) }
        let(:other_shift) { FactoryGirl.create(:shift, :with_restaurant, restaurant: other_restaurant) }
        #blocked actions: create/new, edit/update
        #constrained actions: index(only own restaurant's shifts), show (only own restaurant's shifts)
        it "should be able to access to access blocked paths" do
          check_blocked_paths manager, [  
                                          new_shift_path, #new
                                          new_restaurant_shift_path restaurant, #new
                                          new_restaurant_shift_path other_restaurant, #new
                                          edit_shift_path own_shift, # edit
                                          edit_shift_path other_shift, #edit
                                          shift_path other_shift,  #show(other restaurant's shift)
                                          shifts_path, #index
                                          restaurant_shifts_path other_restaurant, #index
                                        ]
        end

        it "should be able to access permitted paths" do
          check_permitted_paths manager,  [ 
                                            shift_path own_shift, #show
                                            restaurant_shifts_path #index
                                          ] 
        end
      end     
    end
  end
end