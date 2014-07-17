require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb
include RequestSpecMacros # /spec/support/request_spec_macros.rb
include ManagerPageMacros # /spec/support/manager_page_macros.rb

describe "Manager Pages" do
  let!(:restaurant) { FactoryGirl.create(:restaurant) }
  let!(:new_manager) { FactoryGirl.build(:manager, :with_restaurant, restaurant: restaurant) }
  let(:account) { new_manager.account }
  let(:contact) { new_manager.account.contact }
  
  let(:staffer) { FactoryGirl.create(:staffer) }

  before { mock_sign_in staffer }

  subject { page }

  describe "navigating to Manager#new" do
    before { visit edit_restaurant_path(restaurant) }

    it { should have_link('Create new manager', href: new_restaurant_manager_path(restaurant.id)) }
  end

  describe "Manager#new" do
    before { visit  new_restaurant_manager_path(restaurant.id)}
    let(:form_hash) { get_manager_form_hash }
    let(:submit) { 'Create Manager' }
    describe "page contents" do
      it { should have_h1('Create Manager') }
      it { should have_h2("Restaurant: #{restaurant.mini_contact.name}") }
    end

    describe "form submission" do
      
      describe "with invalid input" do
        before { click_button submit }
        it { should have_an_error_message }
      end
      
      describe "with valid input" do
        let!(:old_manager_count) { Manager.count }
        let!(:old_restaurant_manager_count) { restaurant.managers.count }
        let!(:old_account_count) { Account.count }
        let!(:old_contact_count) { Contact.count }
        before do
          fill_in_form form_hash
          click_button submit
        end

        it "should create new instances of relevant models" do
          expect( Manager.count - old_manager_count ).to eq 1
          expect( restaurant.managers.count - old_restaurant_manager_count ).to eq 1
          expect( Account.count - old_account_count ).to eq 1
          expect( Contact.count - old_contact_count ).to eq 1
        end

        describe "after successful submission" do
          it { should have_success_message("Profile created for #{contact.name}") }
          it { should have_h1(restaurant.mini_contact.name) }
        end
      end
    end

    describe "Editing and deleting managers" do

      describe "navigting to Managers#destroy and Managers#edit" do
        before do 
          new_manager.save
          visit restaurant_path restaurant 
        end
        
        describe "page contents" do
          it { should have_link('Delete', href: manager_path(restaurant.managers.first.id)) }
          it { should have_link('Edit', href: edit_restaurant_manager_path(restaurant_id: restaurant.id, id: new_manager.id)) }          
        end


        describe "Managers#destroy" do 
          let!(:old_manager_count) { Manager.count }
          let!(:old_restaurant_manager_count) { restaurant.managers.count }
          before { click_link ("delete_manager_#{new_manager.id}") }

          it "should decrement model counts appropriately" do
            expect( Manager.count - old_manager_count ).to eq -1
            expect( restaurant.managers.count - old_restaurant_manager_count ).to eq -1
          end
        end

        describe "Managers#edit" do
          before { click_link("edit_manager_#{new_manager.id}") }
          let(:save) { 'Save Changes' }

          describe "page contents" do
            it { should have_h1('Edit Manager')}

            describe "form submission" do
             
              describe "with invalid input" do
                before do
                  fill_in 'Name', with: ''
                  click_button save
                end

                it { should have_an_error_message }
              end

              describe "with valid input" do
                before do
                  fill_in 'Name', with: 'Big Jerk'
                  fill_in 'Password', with: 'changeme123'
                  fill_in 'Password confirmation', with: 'changeme123'
                  click_button save
                end               
                it { should have_h1(restaurant.mini_contact.name) } 
                it { should have_success_message("Big Jerk's profile has been updated") }
                specify { expect( contact.reload.name ).to eq 'Big Jerk' }
              end
            end
          end
        end 
      end  
    end
  end
end