# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  phone      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#  email      :string(255)
#  title      :string(255)
#  account_id :integer
#

require 'spec_helper'
include ValidationMacros

describe Contact do

  let(:contact) { FactoryGirl.build(:contact, :without_account) }
  let (:attrs) { [:name, :title, :phone, :email ] }
  subject { contact }

  describe "attributes" do


    it "should respond to all attributes" do
      check_attributes contact, attrs
    end
  end

  describe "validation" do

    it { should be_valid }

    describe "presence validations" do
      it "should be invalid without required attributes" do
        check_required_attributes contact, attrs
      end
    end

    describe "formatting validations" do
      describe "of phone number" do
        
        describe "with non-numeric characters" do
          before { contact.phone =  'A11-111-1111' }
          it { should_not be_valid }
        end
        
        describe "with the wrong number of characters" do
          before { contact.phone =  '11-111-1111' }
          it { should_not be_valid }
        end      
      end

      describe "of name" do

        describe "with too many characters " do
          before { contact.name = 'a'*51 }
          it { should_not be_valid }        
        end
        
        describe "with too few characters" do
          before { contact.name = 'bs' }
          it { should_not be_valid } 
        end
      end

      describe "of title" do

        describe "with too many characters " do
          before { contact.title = 'a'*51 }
          it { should_not be_valid }        
        end
        
        describe "with too few characters" do
          before { contact.title = 'bs' }
          it { should_not be_valid } 
        end
      end

      describe "of email" do  
      
        describe "with blank value" do
          before { contact.email = '' }
          it { should_not be_valid }
        end

        describe "with improperly formatted address" do
          it 'should be invalid' do
            addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
            addresses.each do |invalid_address|
              contact.email = invalid_address
              expect(contact).not_to be_valid
            end      
          end
        end

        describe "with pre-existing address" do
          before { contact.save }
          let(:new_contact) { contact.dup }
          specify { expect(new_contact).not_to be_valid }
         end 
      end       
    end
  end

  describe "associations" do
    it { should respond_to :account }
  end
end
