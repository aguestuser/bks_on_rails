require 'spec_helper'
include CustomMatchers, RequestSpecMacros, ConflictRequestMacros, StafferMailerMacros, RiderPageMacros

describe "Staffer Emails" do
  let(:staffer){ FactoryGirl.create(:staffer) }
  before { mock_sign_in staffer }

  describe "Conflict Notifications" do
    load_conflict_scenario
    let(:mail){ ActionMailer::Base.deliveries.last }

    describe "BATCH CREATE" do

      describe "for rider WITH CONFLICTS" do  
        before { batch_preview_conflicts_for rider }
        let!(:mail_count){ ActionMailer::Base.deliveries.count }

        describe "CLONING" do
          before { click_button 'Same' }


          it "should send an email" do
            expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
          end

          it "should render correct metadata" do
            check_conflict_notification_email_metadata mail, rider
          end

          it "should render correct body" do
            check_conflict_notification_email_body mail, rider, :clone
          end
        end # "CLONING"

        describe "making NEW" do
          before { click_link 'Different' }

          describe "#BATCH_NEW page" do

            describe "clicking SUBMIT with 4 NEW CONFLICTS" do
              before { submit_new_conflicts [ 0,1,4,5 ], true } 

              it "should send an email" do
                expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
              end

              it "should render correct metadata" do
                check_conflict_notification_email_metadata mail, rider
              end

              it "should render correct body" do
                check_conflict_notification_email_body mail, rider, :new
              end            
            end # "clicking SUBMIT"       
          end # "#BATCH_NEW page"
        end # "making NEW"      
      end # "for rider WITH CONFLICTS"

      describe "for rider WITHOUT CONFLICTS" do
        before { batch_preview_conflicts_for other_rider }
        let!(:old_count){ Conflict.count }

        describe "CLONING" do
          before { click_button 'Same' }

          it "shouldn't create any conflicts" do
            expect(Conflict.count).to eq old_count
          end

          it "should redirect to ?" do
            expect(current_path).to eq rider_conflicts_path(other_rider)+'/'
          end
        end # "CLONING"
      end # "for rider WITHOUT CONFLICTS"
    end # "BATCH CREATE"    
  end #"Conflict Notifications

  describe "New Rider Notifications" do
    load_rider_resources
    let!(:mail_count){ ActionMailer::Base.deliveries.count }
    let(:new_form){ get_rider_form_hash 'new' }
    let(:submit) { 'Create Rider' }

    before do 
      visit new_rider_path
      fill_in_form new_form
      click_button submit
    end

    let(:mail){ ActionMailer::Base.deliveries.last }
    let(:new_rider){ Rider.last }

    it "should send an email" do
      expect(ActionMailer::Base.deliveries.count).to eq mail_count + 1
    end

    it "should render correct metadata" do
      check_new_rider_notification_email_metadata mail, new_rider
    end

    it "should render correct body" do
      check_new_rider_notification_email_body mail, new_rider
    end

  end # "New Rider Notifications"
end