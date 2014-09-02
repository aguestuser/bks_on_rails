require 'spec_helper'

describe RiderShifts do
  #RUDIMENTS
  let!(:riders){ 2.times.map { FactoryGirl.create(:rider) } }
  let!(:restaurants){ 2.times.map { FactoryGirl.create(:restaurant) } }
  let!(:shifts) do
    [ 
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[0]) },
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[1]) }
    ]
  end

  # SCENARIOS

  describe "scenario 1" do
    # 1 rider, 1 shift, 1 restaurant
    let(:scenario_1){ [ FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]) ] }
    let(:arr_1){ [ { rider: riders[0], shifts: [ shifts[0][0] ], restaurants: [ restaurants[0] ] } ] }

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_1).array).to eq arr_1
    end
  end
  
  describe "scenario 2" do
    # 1 rider, 2 shifts, 1 restaurant (both shifts at same rest)
    let(:scenario_2) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][1])
      ]
    end
    let(:arr_2) do
      [ { rider: riders[0], shifts: [ shifts[0][0], shifts[0][1] ], restaurants: [ restaurants[0] ] } ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_2).array).to eq arr_2
    end    
  end

  describe "scenario 3" do
    # 1 rider, 2 shifts, 2 restaurants (1 shift at each)
    let(:scenario_3) do
      [
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[1][0])
      ]
    end
    let(:arr_3) do
      [ { rider: riders[0], shifts: [ shifts[0][0], shifts[1][0] ], restaurants: [ restaurants[0], restaurants[1] ] } ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_3).array).to eq arr_3
    end    
  end

  describe "scenario 4" do
    # 2 riders, 2 shifts, 1 restaurant (both shifts at same rest)
    let(:scenario_4) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[0][1])
      ]
    end
    let(:arr_4) do
      [ 
        { rider: riders[0], shifts: [ shifts[0][0] ], restaurants: [ restaurants[0] ] },
        { rider: riders[1], shifts: [ shifts[0][1] ], restaurants: [ restaurants[0] ] }
      ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_4).array).to eq arr_4
    end    
  end

  describe "scenario 5" do
    # 2 riders, 2 shifts, 2 restaurants ()
    let(:scenario_5) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[1][0])
      ]
    end
    let(:arr_5) do
      [ 
        { rider: riders[0], shifts: [ shifts[0][0] ], restaurants: [ restaurants[0] ] },
        { rider: riders[1], shifts: [ shifts[1][0] ], restaurants: [ restaurants[1] ] }
      ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_5).array).to eq arr_5
    end    
  end

  describe "scenario 6" do
    # 2 riders, 4 shifts, 2 restaurants (each rider 1 restaurant)
    let(:scenario_6) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[1][1])
      ]
    end
    let(:arr_6) do
      [ 
        { rider: riders[0], shifts: [ shifts[0][0], shifts[0][1] ], restaurants: [ restaurants[0] ] },
        { rider: riders[1], shifts: [ shifts[1][0], shifts[1][1] ], restaurants: [ restaurants[1] ] }
      ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_6).array).to eq arr_6
    end    
  end

  describe "scenario 7" do
    # 2 riders, 4 shifts, 2 restaurants (each rider 2 restaurants)
      let(:scenario_7) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: shifts[1][1])
      ]
    end
    let(:arr_7) do
      [ 
        { rider: riders[0], shifts: [ shifts[0][0], shifts[1][0] ], restaurants: [ restaurants[0], restaurants[1] ] },
        { rider: riders[1], shifts: [ shifts[0][1], shifts[1][1] ], restaurants: [ restaurants[0], restaurants[1] ] }
      ]
    end

    it "should build the correct array" do
      expect(RiderShifts.new(scenario_7).array).to eq arr_7
    end    
  end

  describe "scenario 8 (empty array)" do
    it "should build the correct array" do
      expect(RiderShifts.new([]).array).to eq []
    end    
  end
end