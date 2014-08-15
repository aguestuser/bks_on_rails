require 'spec_helper'

describe Timeboxable do
  let(:_11am){ Time.zone.local(2014,1,1,11) }
  let(:_5pm){ Time.zone.local(2014,1,1,17) }
  let(:_6pm){ Time.zone.local(2014,1,1,18) }
  let(:_11pm){ Time.zone.local(2014,1,1,23) }


  let(:am_shift){ FactoryGirl.create(:shift, :without_restaurant, start: _11am, :end => _5pm ) }
  let(:pm_shift){ FactoryGirl.create(:shift, :without_restaurant, start: _6pm, :end => _11pm ) }

  describe "methods" do
    describe "set_period" do
      
      it "should set period correctly" do
        expect( pm_shift.period.text.upcase ).to eq 'PM'
      end  
    end    
  end
end