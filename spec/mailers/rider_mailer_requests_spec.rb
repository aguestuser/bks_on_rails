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
  
      
    end

    describe "as Justin" do
      before do  
        mock_sign_in justin
        delegate extra_shift
      end
      let!(:mail){ ActionMailer::Base.deliveries.last }

      it "should send an email" do
        expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
      end

      it "should render correct email contents" do
        check_extra_shift_delegation_email_contents staffer: :justin
      end

    end
  end
end