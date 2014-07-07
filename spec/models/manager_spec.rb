# == Schema Information
#
# Table name: managers
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Manager do
  let(:manager) { FactoryGirl.create(:manager) }
  subject { manager }

  describe "associations" do

    describe "contact info" do
      it { should respond_to(:contact_info) }
      its(:name) { should eq manager.contact_info.name }
      its(:phone) { should eq manager.contact_info.phone }
      its(:email) { should eq manager.contact_info.email }
      its(:title) { should eq manager.contact_info.title }      
    end
    describe "restaurant" do
      it { should respond_to(:restaurant) }
    end  
  end
end
