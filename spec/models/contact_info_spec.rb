# == Schema Information
#
# Table name: contact_infos
#
#  id           :integer          not null, primary key
#  phone        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  contact_id   :integer
#  contact_type :string(255)
#  name         :string(255)
#  email        :string(255)
#  title        :string(255)
#

require 'spec_helper'
include ValidationMacros

describe ContactInfo do

  let(:contact_info) { FactoryGirl.build(:contact_info, :without_contact) }
  let (:attrs) { [:name, :title, :phone, :email ] }
  subject { contact_info }

  describe "attributes" do


    it "should respond to all attributes" do
      check_attributes contact_info, attrs
    end
  end

  describe "validation" do

    it { should be_valid }

    describe "presence validations" do
      it "should be invalid without required attributes" do
        check_required_attributes contact_info, attrs
      end
    end

    describe "formatting validations" do
      describe "of phone number" do
        
        describe "with non-numeric characters" do
          before { contact_info.phone =  'A11-111-1111' }
          it { should_not be_valid }
        end
        
        describe "with the wrong number of characters" do
          before { contact_info.phone =  '11-111-1111' }
          it { should_not be_valid }
        end      
      end

      describe "of name" do

        describe "with too many characters " do
          before { contact_info.name = 'a'*51 }
          it { should_not be_valid }        
        end
        
        describe "with too few characters" do
          before { contact_info.name = 'bs' }
          it { should_not be_valid } 
        end
      end

      describe "of title" do

        describe "with too many characters " do
          before { contact_info.title = 'a'*51 }
          it { should_not be_valid }        
        end
        
        describe "with too few characters" do
          before { contact_info.title = 'bs' }
          it { should_not be_valid } 
        end
      end

      describe "of email" do  
      
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

        describe "with pre-existing address" do
          before { contact_info.save }
          let(:new_contact_info) { contact_info.dup }
          specify { expect(new_contact_info).not_to be_valid }
         end 
      end       
    end
  end
end
