require 'spec_helper'

describe StaffersController do

  let!(:staffer) { FactoryGirl.build(:staffer) }
  let!(:staffer_params) { staffer.attributes }
  let!(:contact_info) { FactoryGirl.build(:contact_info).attributes }
  let!(:contact_info_params) { contact_info.attributes }

  describe "create" do
    it "should create a new staffer" do
      expect { post staffer_path }
    end
    before { post staffer_path }
    specify { expect(response).to redirect_to(staffer_path) }
    specify { expect() }
  end

end
