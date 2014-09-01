require 'spec_helper'
include RequestSpecMacros, RiderMailerMacros

describe "Rider Mailer Requests" do
  load_rider_mailer_scenario

  describe "delegation email" do
    
    let!(:mail_count){ ActionMailer::Base.deliveries.count }

    describe "as Tess" do
      before do
        mock_sign_in tess
        delegate_shift
      end
      let!(:mail){ ActionMailer::Base.deliveries.last }
      
      it "should send an email" do
        expect(ActionMailer::Base.deliveries.count).to eq (mail_count + 1)
      end

      it "should render correct email contents" do
        check_delegation_email_contents
      end
    end
  end
end