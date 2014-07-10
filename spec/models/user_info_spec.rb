# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  email      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

require 'spec_helper'
include ValidationMacros

describe UserInfo do
  
  let(:user_info) { FactoryGirl.create(:user_info, :without_user) }
  subject { user_info }

  describe "attributes" do
    let(:attributes) { [ :title, :email, :user_id ] }
    it "should respond to all attributes" do
      check_attributes user_info, attributes
    end
  end

  describe "validation" do

    it { should be_valid }
    
    describe "of required attributes" do
      let(:req_attrs) { [ :title, :email, :user_id ] }
      it "shoudl be invalid without required attributes" do
        check_required_attributes user_info, req_attrs
      end
    end

    describe "of formatting" do
      describe "of email" do
        
        describe "with blank value" do
          before { user_info.email = '' }
          it { should_not be_valid }
        end
        describe "with improperly formatted address" do
          it 'should be invalid' do
            addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
            addresses.each do |invalid_address|
              user_info.email = invalid_address
              expect(user_info).not_to be_valid
            end      
          end
        end
        describe "with pre-existing address" do
          before { user_info.save }
          let(:new_user_info) { user_info.dup }
          specify { expect(new_user_info).not_to be_valid }
         end 
      end      
    end
  end

  describe "associations" do
    describe "with ContactInfo model" do
      it { should respond_to :contact_info }
      its(:name) { should eq user_info.contact_info.name }  
      its(:phone) { should eq user_info.contact_info.phone } 
    end
  end
end
