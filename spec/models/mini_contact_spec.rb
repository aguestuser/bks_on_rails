# == Schema Information
#
# Table name: mini_contacts
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  phone         :string(255)
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'
include ValidationMacros

describe MiniContact do
  let(:mini_contact) { FactoryGirl.build(:mini_contact, :without_restaurant) }
  let(:attrs) { [ :name, :phone ] }

  subject { mini_contact }

  describe "attributes" do
    it "should respond to all attribtues" do
      check_attributes mini_contact, attrs
    end
  end

  describe "validations" do
    
    it { should be_valid }
    
    it "should be invalid without required attributes" do
      check_required_attributes mini_contact, attrs
    end

    describe "with name that's too long" do 
      before { mini_contact.name = 'a'*51 }
      it { should be_invalid }
    end

    describe "of phone number" do
      
      describe "with non-numeric characters" do
        before { mini_contact.phone =  'A11-111-1111' }
        it { should_not be_valid }
      end
      
      describe "with the wrong number of characters" do
        before { mini_contact.phone =  '11-111-1111' }
        it { should_not be_valid }
      end      
    end
  end

  describe "associations" do
    it { should respond_to :restaurant }
  end
end
