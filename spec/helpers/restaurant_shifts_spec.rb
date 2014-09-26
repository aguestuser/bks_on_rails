require 'spec_helper'

describe "RestaurantShifts" do
  #SCENARIO
  let!(:restaurants){ 2.times.map{ FactoryGirl.create(:restaurant) } }
  let(:week_start){ Time.zone.local(2014,1,6) }
  let(:start_t){ week_start + 12.hours }
  let(:end_t){ week_start + 18.hours }
  let(:week_end){ Time.zone.local(2014,1,12) }

  describe "formatting array" do
    #1 shift in range
    let!(:shifts) do
      [ FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[0], start: start_t, :end => end_t) ]
    end
    let(:expected_arr) do
      [
        { restaurant: restaurants[0], shifts: shifts },
        { restaurant: restaurants[1], shifts: [] }
      ]
    end

    it "should format the array correctly" do
      expect(RestaurantShifts.new( restaurants, week_start ).arr ).to eq expected_arr
    end
  end

  describe "excluding out-of-range shifts" do
    # 1 shift before range, 1 in, 1 after
    let!(:shifts) do
      starts = [ week_start - 12.hours, start_t, week_end.end_of_day + 12.hours ]
      ends = [ week_start - 4.hours, end_t, week_end.end_of_day + 18.hours ]
      3.times.map do |n|
        FactoryGirl.create( :shift, :with_restaurant, restaurant: restaurants[0], start: starts[n], :end => ends[n] )
      end
    end
    let(:expected_arr) do
      [
        { restaurant: restaurants[0], shifts: [ shifts[1] ] },
        { restaurant: restaurants[1], shifts: [] }
      ]
    end

    it "should exclude out-of-range conflicts" do
      expect(RestaurantShifts.new( restaurants, week_start ).arr ).to eq expected_arr
    end
  end

  describe "sorting shifts by date" do
    # 3 shifts in range, in reverse chronological order 
    let!(:shifts) do
      3.times.map { |n| 
        FactoryGirl.create( :shift, :with_restaurant, restaurant: restaurants[0], start: start_t + n.days, :end => end_t + n.days )
      }.reverse
    end
    let(:expected_arr) do
      [
        { restaurant: restaurants[0], shifts: shifts.reverse },
        { restaurant: restaurants[1], shifts: [] }
      ]
    end

    it "should sort shifts by date" do
      expect(RestaurantShifts.new( restaurants, week_start ).arr ).to eq expected_arr
    end
  end

  describe "sorting by restaurant" do
    # 4 conflicts in range, 2 belonging to riders[0], 2 to riders[1]
    let!(:shifts) do
      4.times.map{ |n| 
        the_restaurant = (n+2)%2 == 0 ? restaurants[0] : restaurants[1]
        FactoryGirl.create(:shift, :with_restaurant, restaurant: the_restaurant, start: start_t + n.days, :end => end_t + n.days)
      }
    end
    let(:expected_arr) do
      [
        { restaurant: restaurants[0], shifts: [ shifts[0], shifts[2] ] },
        { restaurant: restaurants[1], shifts: [ shifts[1], shifts[3] ] }
      ]
    end

    it "should sort hashes by restaurant" do
      expect(RestaurantShifts.new( restaurants, week_start ).arr ).to eq expected_arr
    end
  end
end