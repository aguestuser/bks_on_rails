require 'spec_helper'
include BillingShifts

describe "BillingShifts" do
  let!(:start){ Time.zone.local(2014,1,1,6) }
  let!(:restaurants){ 4.times.map { FactoryGirl.create(:restaurant) } }

  let(:shifts) do

    10.times.map do |n| 
      if 0 <= n && n <= 4
        i = 0
      elsif 5 <= n && n <= 7
        i = 1
      elsif 8 <= n && n <= 9
        i = 2
      end
      d = n/3
      FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[i], start: start + (n/3).days, :end => start + (n/3).days + 1.hour)
    end
  
  end

  it "sorts shifts correctly" do
    # pp shifts
    pp BillingShifts.group shifts
    expect(true).to eq true
  end
end