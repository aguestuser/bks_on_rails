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

    describe "authorization" do
      
      describe "as Rando" do
        
        describe "nav links" do
          # should not see any nav links, only "Sign in"
        end

        describe "trying to make edits" do
          # should not be able to make any edits
        end
      end

      describe "as Staffer" do
        
        before { mock_sign_in staffer }

        describe "nav links" do
          #should see all nav links (Restaurants, Riders, Staff, Account > Homepage / Settings / Manual / Sign out )
        end

        describe "profile page" do
          #should see profile page with own info
        end

        describe "viewing Restaurants" do
          #should be able to access restaurants index
          #should be able to edit a restaurant
        end

        describe "viewing Riders" do
          # should be able to access Riders index
          # should be able to edit Rider
        end

        describe "viewing Staffers" do
          # should be able to access Staffers index
          # should be able to 
        end

        describe "viewing Shifts" do
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
          # should not be able to edit another restaurant
          # should be able to edit own profile page
        end

        describe "viewing Riders" do
          # should not be able to access Riders index
          # should not be able to edit any Rider
        end

        describe "viewing Staffers" do
          # should be able to access Staffers index
          # should be able to view staffer profiles
          # should not be able to edit Staffer info 
        end

        describe "viewing Shifts" do
          # should not be able to access full Shifts index
          # should be able to access an index of own restaurant's shifts
          # should not be able to edit shift info for own shifts
          # should not be able view shift info for other restaurants
        end        
      end
    end
  end
end