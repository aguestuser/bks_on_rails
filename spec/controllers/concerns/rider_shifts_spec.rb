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
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: extra_shifts[1][0])
      ]
    end
    before do
      [extra_shifts[0][0],extra_shifts[1][0]].each_with_index { |s, i| s.assignment = assignments[i] }
    end
    let(:expected) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          },
          extra: {
            delegation: {
              shifts: [ extra_shifts[0][0] ],
              restaurants: [ restaurants[0] ]
            },
            confirmation: {
              shifts: [ extra_shifts[1][0] ],
              restaurants: [ restaurants[1] ]
            }
          },
          weekly: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          }
        }
      }
    end

    it "should format rider hash correctly" do
      actual = RiderShifts.new(assignments).hash
      expect(actual).to eq expected
    end
  end # "formatting rider hash"

  describe "grouping by rider" do
    # 2 riders, 1 shift each (each from dif restaurant)
    let(:assignments) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :confirmed, shift: emergency_shifts[1][0])
      ]
    end

    before do
      [ emergency_shifts[0][0], emergency_shifts[1][0] ].each_with_index { |s, i| s.assignment = assignments[i] } 
    end
    
    let(:expected_hash) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: {
            confirmation: {
              shifts: [ emergency_shifts[0][0] ],
              restaurants: [ restaurants[0] ]   
            },
            delegation: { shifts: [], restaurants: [] }
          },
          extra: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          },
          weekly: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          }
        },
        riders[1].id => { 
          rider: riders[1],
          emergency: {
            confirmation: {
              shifts: [ emergency_shifts[1][0] ],
              restaurants: [ restaurants[1] ]   
            },
            delegation: { shifts: [], restaurants: [] }
          },
          extra: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          },
          weekly: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          }
        } 
      }
    end

    it "should group by rider" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end # "grouping by rider"

  describe "grouping by shift type" do
    # 2 riders, 1 shift each (each from dif restaurant)
    let(:assignments) do 
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: weekly_shifts[0][0]), 
      ]
    end

    before do
      [
        emergency_shifts[0][0],
        extra_shifts[0][0],
        weekly_shifts[0][0]
      ].each_with_index { |s, i| s.assignment = assignments[i] }
    end

    let(:expected_hash) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: {
              shifts: [ emergency_shifts[0][0] ],
              restaurants: [ restaurants[0] ] 
            }
          },
          extra: {
            delegation: { 
              shifts: [ extra_shifts[0][0] ], 
              restaurants: [ restaurants[0] ] 
            },
            confirmation: { shifts: [], restaurants: [] }
          },
          weekly: { 
            delegation: { 
              shifts: [ weekly_shifts[0][0] ], 
              restaurants: [ restaurants[0] ] 
            },
            confirmation: { shifts: [], restaurants: [] }
          }
        }
      }
    end

    it "should group by shift type" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end # "grouping by shift type"

  describe "grouping by rider, urgency, and email type" do
    # 1 rider, 2 shifts, 2 restaurants (1 shift at each)
    let(:assignments) do
      [
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: emergency_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: emergency_shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :confirmed, shift: extra_shifts[1][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: weekly_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: weekly_shifts[1][0]),

        FactoryGirl.create(:assignment, rider: riders[1], status: :confirmed, shift: emergency_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :confirmed, shift: emergency_shifts[1][1]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :delegated, shift: extra_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :confirmed, shift: extra_shifts[1][1]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :delegated, shift: weekly_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[1], status: :delegated, shift: weekly_shifts[1][1]),        
      ]
    end

    before do
      [
        emergency_shifts[0][0],
        emergency_shifts[1][0],
        extra_shifts[0][0],
        extra_shifts[1][0],
        weekly_shifts[0][0],
        weekly_shifts[1][0],

        emergency_shifts[0][1],
        emergency_shifts[1][1],
        extra_shifts[0][1],
        extra_shifts[1][1],
        weekly_shifts[0][1],
        weekly_shifts[1][1]
        
      ].each_with_index { |s, i| s.assignment = assignments[i] }
    end

    let(:expected_hash) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: {
            delegation: { shifts: [], restaurants: [] },
            confirmation: {
              shifts: [ emergency_shifts[0][0], emergency_shifts[1][0] ],
              restaurants: restaurants  
            }
          },
          extra: { 
            delegation: { 
              shifts: [ extra_shifts[0][0] ], 
              restaurants: [ restaurants[0] ]
            },
            confirmation: { 
              shifts: [ extra_shifts[1][0] ], 
              restaurants: [ restaurants[1] ]
            }
          },
          weekly: { 
            delegation: { 
              shifts: [ weekly_shifts[0][0], weekly_shifts[1][0] ], 
              restaurants: restaurants
            },
            confirmation: { shifts: [], restaurants: [] }
          }
        },
        riders[1].id => { 
          rider: riders[1], 
          emergency: {
            delegation: { shifts: [], restaurants: [] },
            confirmation: {
              shifts: [ emergency_shifts[0][1], emergency_shifts[1][1] ],
              restaurants: restaurants  
            }
          },
          extra: { 
            delegation: { 
              shifts: [ extra_shifts[0][1] ], 
              restaurants: [ restaurants[0] ]
            },
            confirmation: { 
              shifts: [ extra_shifts[1][1] ], 
              restaurants: [ restaurants[1] ]
            }
          },
          weekly: { 
            delegation: { 
              shifts: [ weekly_shifts[0][1], weekly_shifts[1][1] ], 
              restaurants: restaurants
            },
            confirmation: { shifts: [], restaurants: [] }
          }
        } 
      }
    end

    it "should group by rider and shift type" do
      actual = RiderShifts.new(assignments).hash
      expect(actual).to eq expected_hash
    end
  end # "grouping by rider and shift type"

  describe "deduping restaurants" do
    let(:assignments) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][0]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][1])
      ]
    end

    before do
      [ extra_shifts[0][0], extra_shifts[0][1] ].each_with_index { |s, i| s.assignment = assignments[i] }
    end

    let(:expected_hash) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          },
          extra: {
            delegation: {
              shifts: [ extra_shifts[0][0], extra_shifts[0][1] ],
              restaurants: [ restaurants[0] ]
            },
            confirmation: { shifts: [], restaurants: [] }
          },
          weekly: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          }
        }
      }
    end

    it "should dedupe restaurants" do
      actual = RiderShifts.new(assignments).hash
      expect(actual).to eq expected_hash
    end
  end #"deduping restaurants"

  describe "sorting by date" do
    let(:assignments) do
      [ 
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][1]),
        FactoryGirl.create(:assignment, rider: riders[0], status: :delegated, shift: extra_shifts[0][0])
      ]
    end

    before do
      [ extra_shifts[0][1], extra_shifts[0][0] ].each_with_index { |s, i| s.assignment = assignments[i] }
    end

    let(:expected_hash) do
      {
        riders[0].id => { 
          rider: riders[0], 
          emergency: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          },
          extra: {
            delegation: {
              shifts: [ extra_shifts[0][0], extra_shifts[0][1] ],
              restaurants: [ restaurants[0] ]
            },
            confirmation: { shifts: [], restaurants: [] }
          },
          weekly: { 
            delegation: { shifts: [], restaurants: [] },
            confirmation: { shifts: [], restaurants: [] }
          }
        }
      }
    end

    it "should sort by date" do
      expect(RiderShifts.new(assignments).hash).to eq expected_hash
    end
  end #"sorting by date"
end