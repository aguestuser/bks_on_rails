# == Schema Information
#
# Table name: work_specifications
#
#  id                     :integer          not null, primary key
#  restaurant_id          :integer
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  extra_work_description :text
#  created_at             :datetime
#  updated_at             :datetime
#  extra_work             :boolean
#

require 'spec_helper'
include ValidationMacros

describe WorkSpecification do
  let(:work_spec) { FactoryGirl.build(:work_specification, :without_restaurant) }
  let(:attrs) { [ :zone, :daytime_volume, :evening_volume, :extra_work, :extra_work_description ] }

  subject { work_spec }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes work_spec, attrs
    end
  end

  describe "validation" do

    it { should be_valid }

    let(:required_attrs) { attrs[0..3] }

    it "shouldn't be valid without required fields" do

      check_required_attributes work_spec, required_attrs
    end

    describe "with extra work" do
      before do 
        work_spec.extra_work = true
        work_spec.extra_work_description = nil
      end

      it { should_not be_valid }
    end
  end
end
