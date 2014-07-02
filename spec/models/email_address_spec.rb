require 'spec_helper'

describe EmailAddress do

  let(:email_address) { FactoryGirl.create(:email_address) }
  
  subject { email_address }

  describe "attributes" do
    it { should respond_to(:primary) }
    it { should respond_to(:value) }
  end

  describe "validation" do

    it { should be_valid }

    describe "of primary" do
      before { email_address.primary = nil }
      it { should_not be_valid }
    end

    describe "of value" do
      
      describe "with blank value" do
        before { email_address.value = '' }
        it { should_not be_valid }
      end

      describe "with improperly formatted address" do
        it 'should be invalid' do
          addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
          addresses.each do |invalid_address|
            email_address.value = invalid_address
            expect(email_address).not_to be_valid
          end      
        end
      end 
    end
  end
end