# == Schema Information
#
# Table name: rider_ratings
#
#  id             :integer          not null, primary key
#  rider_id       :integer
#  initial_points :integer
#  likeability    :integer
#  reliability    :integer
#  speed          :integer
#  points         :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'
include ValidationMacros

describe RiderRating do
  let(:rating) { FactoryGirl.build(:rider_rating, :without_rider ) }
  let(:attrs) { [ :initial_points, :likeability, :reliability, :speed, :points ] }

  subject { rating }

  describe "attributes" do
    it "should respond to all attributes" do
      check_attributes rating, attrs
    end
  end

  describe "validations" do
    it { should be_valid }
    it "shouldn't be valid without all required attributes" do
      check_required_attributes rating, attrs
    end
    it "shouldn't be valid when numerical fields have non-numerical input" do
      check_numericality rating, attrs
    end
    describe "initial points" do
      describe "with number outside accepted range" do
        before { rating.initial_points = 3 }
        it { should_not be_valid }
      end
    end
    describe "ratings" do
      describe "with number outside accepted range" do
        before { rating.likeability = 5 }
        it { should_not be_valid }
      end
    end
  end

  describe "callbacks" do
    before { rating.save }
    it "should intialize points" do
      expect(rating.points).to eq rating.initial_points
    end
  end
end
