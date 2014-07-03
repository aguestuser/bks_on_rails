# == Schema Information
#
# Table name: contact_infos
#
#  id             :integer          not null, primary key
#  phone          :string(255)
#  email          :string(255)
#  street_address :string(255)
#  borough        :string(255)
#  neighborhood   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe ContactInfo do

  let(:contact_info) { FactoryGirl.create(:contact_info) }
  subject { contact_info }

  describe "attributes" do
    it { should respond_to(:phone) }
    it { should respond_to(:email) }
    it { should respond_to(:street_address) }
    it { should respond_to(:borough) }
    it { should respond_to(:neighborhood) }
  end

  describe "validation" do

    it { should be_valid }

    describe "of phone number" do
      
      describe "with blank value" do
        before { contact_info.phone = '' }
        it { should_not be_valid }
      end
      describe "with non-numeric characters" do
        before { contact_info.phone =  'A11-111-1111' }
        it { should_not be_valid }
      end
      describe "with the wrong number of characters" do
        before { contact_info.phone =  '11-111-1111' }
        it { should_not be_valid }
      end      
    end

    describe "of email address" do
      
      describe "with blank value" do
        before { contact_info.email = '' }
        it { should_not be_valid }
      end
      describe "with improperly formatted address" do
        it 'should be invalid' do
          addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
          addresses.each do |invalid_address|
            contact_info.email = invalid_address
            expect(contact_info).not_to be_valid
          end      
        end
      end 
    end

    describe "of street address" do
          
      describe "with no value" do
        before { contact_info.street_address = nil }
        it { should_not be_valid }
      end
      describe "with borough in address" do
        it "should be invalid" do
          boroughs = %w[Brooklyn brooklyn Queens Bronx Manhattan Staten NYC]
          boroughs.each do |borough|
            contact_info.street_address = "#{contact_info.street_address} #{borough}" 
            expect(contact_info).not_to be_valid
          end   
        end
      end
      describe "with 'NY' in address" do
        before { contact_info.street_address = "#{contact_info.street_address} NY" }
        it { should_not be_valid }
      end
    end

    describe "of borough" do
      
      describe "with no value" do
        before { contact_info.borough = nil }
        it { should_not be_valid }
      end
      describe "with incorrect value" do
        before { contact_info.borough = 'long island' }
        it { should_not be_valid }
      end
    end

    describe "of neighborhood" do
      
      describe "with no value" do
        before { contact_info.neighborhood = nil }
        it { should_not be_valid }
      end
      describe "with incorrect value" do
        before { contact_info.neighborhood = 'hoboken' }
        it { should_not be_valid }
      end
    end
  end
end
