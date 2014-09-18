require 'spec_helper'
include RequestSpecMacros, RiderMailerMacros

describe "Rider Mailer Requests" do
  load_staffers

  describe "DELEGATION EMAIL" do
    load_delegation_scenario

    describe "as Tess" do
      before { mock_sign_in tess }

      describe "for extra shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { assign extra_shift, 'Delegated' }
        let(:mail){ ActionMailer::Base.deliveries.last }
      
        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        
        it "should render correct email metadata" do
          check_delegation_email_metadata mail, :tess, :extra
        end
        
        it "should render correct email body" do
          check_delegation_email_body mail, :tess, :extra
        end
      end

      describe "for emergency shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { assign emergency_shift, 'Confirmed' }
        let(:mail){ ActionMailer::Base.deliveries.last }

        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        
        it "should render correct email metadata" do
          check_delegation_email_metadata mail, :tess, :emergency
        end
        
        it "should render correct email body" do
          check_delegation_email_body mail, :tess, :emergency
        end
      end

      describe "trying to delegate an emergency shift" do
        before { assign emergency_shift, 'Delegated' }

        it "should redirect to error-handling page" do
          expect(page).to have_h1 'Batch Assign Shifts'  
        end

        it "should list shifts with errors correctly" do
          expect(page.within("#assignments_fresh_0"){ find(".field_with_errors").text }).to include(rider.name)
        end
      end # "trying to delegate an emergency shift"
    end # "as Tess"

    describe "as Justin" do
      before { mock_sign_in justin }

      describe "for extra shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { assign extra_shift, 'Delegated' }
        let(:mail){ ActionMailer::Base.deliveries.last }
        
        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        
        it "should render correct email metadata" do
          check_delegation_email_metadata mail, :justin, :extra
        end
        
        it "should render correct email body" do
          check_delegation_email_body mail, :justin, :extra
        end
      end
    end #"as Justin"
  end # "ASSIGNMENT EMAIL"

  describe "BATCH DELEGATION EMAILS" do
    load_delegation_scenario
    load_batch_delegation_scenario

    describe "as Tess" do
      before { mock_sign_in tess }

      describe "for EXTRA shifts" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count } 
        before { batch_delegate extra_shifts, :extra }
        let(:mails){ ActionMailer::Base.deliveries.last(2) }

        it "should send 2 emails" do
          expect( ActionMailer::Base.deliveries.count ).to eq mail_count + 2
        end

        it "should format email metadata correctly" do
          check_batch_delegation_email_metadata mails, :extra
        end

        it "should format email body correctly" do
          check_batch_delegation_email_body mails, :tess, :extra
        end
      end # "for EXTRA shifts"

      describe "for EMERGENCY shifts" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count } 
        before { batch_delegate emergency_shifts, :emergency }
        let(:mails){ ActionMailer::Base.deliveries.last(2) }

        it "should send 2 emails" do
          expect( ActionMailer::Base.deliveries.count ).to eq mail_count + 2
        end

        it "should format email metadata correctly" do
          check_batch_delegation_email_metadata mails, :emergency
        end

        it "should format email body correctly" do
          check_batch_delegation_email_body mails, :tess, :emergency
        end
      end # "for EMERGENCY shifts"

      describe "for MIXED BATCH of shifts" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count } 
        before { batch_delegate mixed_batch, :mixed }
        let(:mails){ ActionMailer::Base.deliveries.last(4) }

        it "should send 4 emails" do
          expect( ActionMailer::Base.deliveries.count ).to eq mail_count + 4
        end

        it "should format email metadata correctly" do
          check_mixed_batch_delegation_email_metadata mails
        end

        it "should format email body correctly" do
          check_batch_delegation_email_body mails, :tess, :mixed
        end
      end # "for "for MIXED BATCH of shifts"

      describe "trying to DELEGATE EMERGENCY shifts" do
        before { batch_delegate emergency_shifts, :emergency_delegation }

        it "should redirect to error-handling page" do
          expect(page).to have_h1 'Batch Assign Shifts'  
        end

        it "should list shifts with errors correctly" do
          expect(page.within("#assignments_fresh_0"){ find(".field_with_errors").text }).to include(rider.name)
          expect(page.within("#assignments_fresh_1"){ find(".field_with_errors").text }).to include(rider.name)
          expect(page.within("#assignments_fresh_2"){ find(".field_with_errors").text }).to include(rider.name)
          expect(page.within("#assignments_fresh_3"){ find(".field_with_errors").text }).to include(rider.name)
        end
      end # "trying to DELEGATE EMERGENCY shifts"
    end # "as Tess"
  end # "BATCH ASSIGNMENT EMAILS"

  describe "CONFLICT REQUEST" do
    load_conflict_request_scenario

    before(:all) do # deactive all riders
      @active = Rider.find(Rider.active.map(&:id))
      @active.each{ |rider| rider.update(active: false) }
    end

    after(:all) do # reactivate all riders who were active before tests
      @active.each{ |record| record.update(active: true) }
    end
    
    before(:each) do 
      riders.each{ |rider| rider.update(active: true) }
      mock_sign_in tess
      click_link 'Request Conflicts'
      click_link 'Send Emails', match: :first
    end

    it "should send emails to all active riders" do
      expect(ActionMailer::Base.deliveries.count).to eq 3
    end

    let(:mails){ ActionMailer::Base.deliveries.last(3) }

    it "should render correct email metadata" do
      check_conflict_request_metadata mails, :tess
    end

    it "should render correct email bodies" do
      check_conflict_request_email_bodies mails, :tess
    end

  end
end