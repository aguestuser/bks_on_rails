require 'spec_helper'

describe RiderShifts do
  #RUDIMENTS
  let!(:riders){ 2.times.map { FactoryGirl.create(:rider) } }
  let!(:restaurants){ 2.times.map { FactoryGirl.create(:restaurant) } }
  let!(:extra_shifts) do
    [ 
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[0], urgency: :extra ) },
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[1], urgency: :extra ) }
    ]
  end
  let!(:emergency_shifts) do
    [ 
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[0], urgency: :emergency ) },
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[1], urgency: :emergency ) }
    ]
  end
  let!(:weekly_shifts) do
    [ 
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[0], urgency: :weekly ) },
      2.times.map { FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[1], urgency: :weekly ) }
    ]
  end

  # SCENARIOS

  describe "formatting rider hash" do
    # 1 rider, 2 shifts, 1 restaurant (both shifts at same rest)
    let(:assignments) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[1][0])
      ]
    end
    let(:expected_hash) do
      hash = {}
      hash[riders[0].id] = { 
        rider: riders[0], 
        emergency: {
          shifts: [ emergency_shifts[0][0], emergency_shifts[1][0] ],
          restaurants: [ restaurants[0], restaurants[1] ] 
        },
        extra: { shifts: [], restaurants: [] },
        weekly: { shifts: [], restaurants: [] }
      }
      hash
    end

    it "should format rider hash correctly" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end

  describe "grouping by rider" do
    # 2 riders, 1 shift each (each from dif restaurant)
    let(:assignments) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: emergency_shifts[1][0])
      ]
    end
    let(:expected_hash) do
      hash = {}
      hash[riders[0].id] = { 
        rider: riders[0], 
        emergency: {
          shifts: [ emergency_shifts[0][0] ],
          restaurants: [ restaurants[0] ] 
        },
        extra: { shifts: [], restaurants: [] },
        weekly: { shifts: [], restaurants: [] }
      }
      hash[riders[1].id] = { 
        rider: riders[1], 
        emergency: {
          shifts: [ emergency_shifts[1][0] ],
          restaurants: [ restaurants[1] ] 
        },
        extra: { shifts: [], restaurants: [] },
        weekly: { shifts: [], restaurants: [] }
      }
      hash
    end

    it "should group by rider" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end

  describe "grouping by shift type" do
    # 2 riders, 1 shift each (each from dif restaurant)
    let(:assignments) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: weekly_shifts[0][0]), 
      ]
    end
    let(:expected_hash) do
      hash = {}
      hash[riders[0].id] = { 
        rider: riders[0], 
        emergency: {
          shifts: [ emergency_shifts[0][0] ],
          restaurants: [ restaurants[0] ] 
        },
        extra: { 
          shifts: [ extra_shifts[0][0] ], 
          restaurants: [ restaurants[0] ] 
        },
        weekly: { 
          shifts: [ weekly_shifts[0][0] ], 
          restaurants: [ restaurants[0] ] 
        }
      }
      hash
    end

    it "should group by shift type" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end

  describe "grouping by rider and shift type" do
    # 1 rider, 2 shifts, 2 restaurants (1 shift at each)
    let(:assignments) do
      [
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: extra_shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: weekly_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], shift: weekly_shifts[1][0]),

        FactoryGirl.create(:assignment, rider: riders[1], shift: emergency_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: emergency_shifts[1][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: extra_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: extra_shifts[1][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: weekly_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], shift: weekly_shifts[1][1]),        
      ]
    end
    let(:expected_hash) do
      hash = {}
      hash[riders[0].id] = { 
        rider: riders[0], 
        emergency: {
          shifts: [ emergency_shifts[0][0], emergency_shifts[1][0] ],
          restaurants: restaurants 
        },
        extra: { 
          shifts: [ extra_shifts[0][0], extra_shifts[1][0] ], 
          restaurants: restaurants
        },
        weekly: { 
          shifts: [ weekly_shifts[0][0], weekly_shifts[1][0] ], 
          restaurants: restaurants
        }
      }
      hash[riders[1].id] = { 
        rider: riders[1], 
        emergency: {
          shifts: [ emergency_shifts[0][1], emergency_shifts[1][1] ],
          restaurants: restaurants 
        },
        extra: { 
          shifts: [ extra_shifts[0][1], extra_shifts[1][1] ], 
          restaurants: restaurants
        },
        weekly: { 
          shifts: [ weekly_shifts[0][1], weekly_shifts[1][1] ], 
          restaurants: restaurants
        }
      }      
      hash
    end

    it "should group by rider and shift type" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end

    describe "deduping restaurants" do
      let(:assignments) do
        [
          FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0]),
          FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][1])
        ]
      end
      let(:expected_hash) do
        {
          riders[0].id => {
            rider: riders[0],
            emergency: {
              shifts: emergency_shifts[0],
              restaurants: [ restaurants[0] ]
            },
            extra: { shifts: [], restaurants: [] },
            weekly: { shifts: [], restaurants: [] }
          }
        }
      end

      it "should dedupe restaurants" do
        expect(RiderShifts.new(assignments).hash).to eq expected_hash
      end
    end 

    describe "sorting by date" do
      let(:assignments) do
        [
          FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][1]),
          FactoryGirl.create(:assignment, rider: riders[0], shift: emergency_shifts[0][0])
        ]
      end
      let(:expected_hash) do
        {
          riders[0].id => {
            rider: riders[0],
            emergency: {
              shifts: emergency_shifts[0],
              restaurants: [ restaurants[0] ]
            },
            extra: { shifts: [], restaurants: [] },
            weekly: { shifts: [], restaurants: [] }
          }
        }
      end

      it "should sort by date" do
        expect(RiderShifts.new(assignments).hash).to eq expected_hash
      end
    end     
  end
end