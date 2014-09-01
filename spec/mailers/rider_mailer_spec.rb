require "spec_helper"
include RiderMailerMacros

describe RiderMailer do
  load_rider_mailer_scenario

  describe "#delegation_email" do
    load_delegation_email_scenario

    it "should render correct email contents" do
      check_delegation_email_contents
    end     
  end
end
