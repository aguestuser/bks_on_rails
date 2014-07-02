# == Schema Information
#
# Table name: phone_numbers
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  primary    :boolean
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe PhoneNumber do

  let(:phone_number) { FactoryGirl.create(:phone_number) }

  subject { phone_number }

  describe "attributes" do
    it { should respond_to(:type) }
    it { should respond_to(:primary) }
    it { should respond_to(:value) }
  end

  describe "validation" do

    it { should be_valid }
    
    describe "of type" do
      before { phone_number.type = nil }
      it { should_not be_valid }
    end

    describe "of primary" do
      before { phone_number.primary = nil }
      it { should_not be_valid }
    end

    describe "of value" do
      
      describe "with blank value" do
        before { phone_number.value = '' }
        it { should_not be_valid }
      end

      describe "with non-numeric characters" do
        before { phone_number.value =  'A11-111-1111' }
        it { should_not be_valid }
      end

      describe "with the wrong number of characters" do
        before { phone_number.value =  '11-111-1111' }
        it { should_not be_valid }
      end      
    end
  end
end
