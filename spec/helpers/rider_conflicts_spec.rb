require 'spec_helper'

describe "RiderConflicts" do
  #RUDIMENTS
  let!(:riders){ 2.times.map{ FactoryGirl.create(:rider) } }
  let(:week_start){ Time.zone.local(2014,1,6) }
  let(:start_t){ week_start + 12.hours }
  let(:end_t){ week_start + 18.hours }
  let(:week_end){ Time.zone.local(2014,1,12) }

  describe "formatting array" do
    # 1 conflict in range
    let!(:conflicts) do 
      [ FactoryGirl.create( :conflict, :with_rider, rider: riders[0], start: start_t, :end => end_t ) ]
    end
    let(:expected_arr) do 
      [ 
        { rider: riders[0], conflicts: conflicts },
        { rider: riders[1], conflicts: [] }
      ]
    end
    
    it "should format the array correctly" do
      expect( RiderConflicts.new( riders, week_start ).arr ).to eq expected_arr
    end
  end

  describe "excluding out-of range conflicts" do
    # 1 conflict in range, 1 before, 1 after
    let!(:conflicts) do
      starts = [ week_start - 12.hours, start_t, week_end.end_of_day + 12.hours ]
      ends = [ week_start - 4.hours, end_t, week_end.end_of_day + 18.hours ]
      3.times.map do |n|
        FactoryGirl.create( :conflict, :with_rider, rider: riders[0], start: starts[n], :end => ends[n] )
      end
    end
    
    let(:expected_arr) do
      [
        { rider: riders[0], conflicts: [ conflicts[1] ] },
        { rider: riders[1], conflicts: [] }
      ]
    end

    it "should exclude out-of-range conflicts" do
      expect( RiderConflicts.new( riders, week_start ).arr ).to eq expected_arr
    end
  end

  describe "sorting conflicts by date" do
    # 3 conflicts in range 
    let!(:conflicts) do
      3.times.map { |n| 
        FactoryGirl.create( :conflict, :with_rider, rider: riders[0], start: start_t + n.days, :end => end_t + n.days )
      }.reverse
    end
    let(:expected_arr) do
      [
        { rider: riders[0], conflicts: conflicts.reverse },
        { rider: riders[1], conflicts: [] }
      ]
    end

    it "should sort conflicts by date" do
      expect( RiderConflicts.new( riders, week_start ).arr ).to eq expected_arr
    end
  end

  describe "sorting by rider" do
    # 4 conflicts in range, 2 belonging to riders[0], 2 to riders[1]
    let!(:conflicts) do
      4.times.map{ |n| 
        the_rider = (n+2)%2 == 0 ? riders[0] : riders[1]
        FactoryGirl.create(:conflict, :with_rider, rider: the_rider, start: start_t + n.days, :end => end_t + n.days)
      }
    end
    let(:expected_arr) do
      [
        { rider: riders[0], conflicts: [ conflicts[0], conflicts[2] ] },
        { rider: riders[1], conflicts: [ conflicts[1], conflicts[3] ] }
      ]
    end

    it "should sort conflicts by rider" do
      expect( RiderConflicts.new( riders, week_start ).arr ).to eq expected_arr
    end
  end
end