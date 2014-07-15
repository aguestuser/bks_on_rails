require 'spec_helper'
include RequestSpecMacros

describe "Authentication" do
  subject { page }

  describe "sign in" do
    let(:staffer) { FactoryGirl.create(:staffer) }
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

      describe "nav links" do
        #should see all nav links (Restaurants, Riders, Staff, Account > Homepage / Settings / Manual / Sign out )
      end

      describe "profile page" do
        before { click_link 'Home' }
        #should see profile page with own info
      end

      describe "viewing Restaurants" do
        before { click_link 'Restaurants' }
        #should be able to access restaurants index
        #should be able to edit a restaurant
      end

      describe "viewing Riders" do
        before { click_link 'Riders' }
        # should be able to access Riders index
        # should be able to edit Rider
      end

      describe "viewing Staffers" do
        before { click_link 'Staffers' }
        # should be able to access Staffers index
        # should be able to 
      end

      describe "viewing Shifts" do
        before { click_link 'Shifts' }
        # should be able to access Shifts index
        # should be able to access list of shifts for several restaurants
      end
    end

    describe "as Manager" do
      describe "nav links" do
        #should only see following nav links: Account > Homepage / Settings / Sign out)
      end

      describe "profile page" do
        before { click_link 'Homepage' }
        #should see profile page with own info
      end

      describe "viewing Restaurants" do
        # should not be able to access restaurants index
        # should not be able to view another restaurant
        # should not be able to create another restaurant
        # should not be able to edit another restaurant
        # should be able to edit own profile page
      end

      describe "viewing Riders" do
        # should not be able to access Riders index
        # should not be able to view any rider
        # should not be able to create another any rider
        # should not be able to edit another any rider
      end

      describe "viewing Staffers" do
        # should be able to access Staffers index
        # should be able to view staffer profiles
        # should not be able to edit any staffer
        # should not be able to create a staffer
         
      end

      describe "viewing Shifts" do
        # should not be able to access full Shifts index
        # should not be able to create a shift
        # should not be able to edit any shift
        # should not be able to view a shift belonging to another restaurant
        # should be able to access an index of own restaurant's shifts
        # should not be able to view a shift belonging to own restaurant
      end        
    end
  end
end