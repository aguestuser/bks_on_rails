# == Schema Information
#
# Table name: short_contact_infos
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

describe ShortContactInfo do
  let(:short_contact_info) { FactoryGirl.build(:short_contact_info) }
  let(:attrs) { [ :name, :phone ] }

  subject { short_contact_info }

  describe "attributes" do
    it "should respond to all attribtues" do
      check_attributes short_contact_info, attrs
    end
  end

  describe "validations" do
    
    it { should be_valid }
    
    it "should be invalid without required attributes" do
      check_required_attributes short_contact_info, attrs
    end

    describe "with name that's too long" do 
      before { short_contact_info.name = 'a'*51 }
      it { should be_invalid }
    end
  end

  describe "associations" do
    it { should respond_to :restaurant }
  end
end
