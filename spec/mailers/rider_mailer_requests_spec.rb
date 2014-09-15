require 'spec_helper'
include RequestSpecMacros, RiderMailerMacros

describe "Rider Mailer Requests" do
  load_rider_mailer_scenario

  describe "DELEGATION EMAIL" do

    describe "as Tess" do
      before { mock_sign_in tess }

      describe "for extra shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { delegate extra_shift }
        let(:mail){ ActionMailer::Base.deliveries.last }
      
        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        it "should render correct email metadata" do
          check_delegation_email_metadata :tess, :extra
        end
      end

      describe "for emergency shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { delegate emergency_shift }
        let(:mail){ ActionMailer::Base.deliveries.last }

        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        it "should render correct email metadata" do
          check_delegation_email_metadata mail, :tess, :emergency
        end
      end
    end # "as Tess"

    describe "as Justin" do
      before { mock_sign_in justin }

      describe "for extra shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { delegate extra_shift }
        let(:mail){ ActionMailer::Base.deliveries.last }
        
        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end

        it "should render correct email metadata" do
          check_delegation_email_metadata mail, :justin, :extra
        end
      end
    end #"as Justin"
  end # "DELEGATION EMAIL"

  describe "BATCH DELEGATION EMAILS" do
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

        it "should redirect to shifts page" do
          expect(page).to have_h1 'Shifts'
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

        it "should redirect to shifts page" do
          expect(page).to have_h1 'Shifts'
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

        it "should redirect to shifts page" do
          expect(page).to have_h1 'Shifts'
        end
      end # "for "for MIXED BATCH of shifts"
    end # "as Tess"
  end # "BATCH DELEGATION EMAILS"
end