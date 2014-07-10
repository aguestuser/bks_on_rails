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
#

require 'spec_helper'
include ValidationMacros

describe ContactInfo do

  let(:contact_info) { FactoryGirl.build(:contact_info, :without_contact) }
  subject { contact_info }

  describe "attributes" do

    let (:attributes) { [:name, :phone] }
    it "should respond to all attributes" do
      check_attributes contact_info, attributes
    end
  end

  describe "validation" do

    it { should be_valid }

    describe "presence validations" do
      let(:required_attrs) { [:name, :phone] }
      it "should be invalid without required attributes" do
        check_required_attributes contact_info, required_attrs
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
          before { contact_info.name = 'a'*31 }
          it { should_not be_valid }        
        end
        describe "with too few characters" do
          before { contact_info.name = 'bs' }
          it { should_not be_valid } 
        end
      end      
    end
  end
end
