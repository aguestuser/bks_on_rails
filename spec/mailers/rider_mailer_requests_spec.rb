require 'spec_helper'
include RequestSpecMacros, RiderMailerMacros

describe "Rider Mailer Requests" do
  load_rider_mailer_scenario

  describe "delegation email" do

    describe "as Tess" do
      before { mock_sign_in tess }

      describe "for extra shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { delegate extra_shift }
        let(:mail){ ActionMailer::Base.deliveries.last }
      
        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        it "should render correct email contents" do
          check_shift_delegation_email_contents :tess, :extra, extra_shift
        end
      end

      describe "for emergency shift" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count }
        before { delegate emergency_shift }
        let(:mail){ ActionMailer::Base.deliveries.last }

        it "should send an email" do
          expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
        end
        it "should render correct email contents" do
          check_shift_delegation_email_contents :tess, :emergency, emergency_shift
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

        it "should render correct email contents" do
          check_shift_delegation_email_contents :justin, :extra, extra_shift
        end
      end
    end #"as Justin"
  end # delegation email

  describe "batch delegation email" do
    load_batch_delegation_scenario

    describe "as Tess" do
      before { mock_sign_in tess }


      describe "for extra shifts" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count } 
        before { batch_delegate extra_shifts }
        let(:mails){ ActionMailer::Base.deliveries.last(2) }

        it "should redirect to shifts page" do
          expect(page).to have_h1 'Shifts'
        end

        it "should send 2 emails" do
          expect( ActionMailer::Base.deliveries.count ).to eq mail_count + 2
        end

        it "should format emails correctly" do
          check_batch_delegation_email_contents :tess, :extra, extra_shifts
        end
      end # "for extra shifts"

      describe "for emergency shifts" do
        let!(:mail_count){ ActionMailer::Base.deliveries.count } 
        before { batch_delegate extra_shifts }
        let(:mails){ ActionMailer::Base.deliveries.last(2) }

        it "should send 2 emails" do
          expect( ActionMailer::Base.deliveries.count ).to eq mail_count + 2
        end

        it "should format emails correctly" do
          check_batch_delegation_email_contents :tess, :extra, extra_shifts
        end
      end # "for emergency shifts"
    end # "as Tess"
  end # "batch delegation email"
end