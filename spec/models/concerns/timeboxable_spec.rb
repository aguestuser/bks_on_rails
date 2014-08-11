require 'spec_helper'

describe Timeboxable do
  # let(:_11am){ DateTime.new(2014,1,1,11,0,0,'-5') }
  # let(:_5pm){ DateTime.new(2014,1,1,17,0,0,'-5') }
  # let(:_6pm){ DateTime.new(2014,1,1,18,0,0,'-5') }
  # let(:_11pm){ DateTime.new(2014,1,1,23,0,0,'-5') }
  let(:_11am){ Time.zone.local(2014,1,1,11) }
  let(:_5pm){ Time.zone.local(2014,1,1,17) }
  let(:_6pm){ Time.zone.local(2014,1,1,18) }
  let(:_11pm){ Time.zone.local(2014,1,1,23) }


  let(:am_shift){ FactoryGirl.create(:shift, :without_restaurant, start: _11am, :end => _5pm ) }
  let(:pm_shift){ FactoryGirl.create(:shift, :without_restaurant, start: _6pm, :end => _11pm ) }

  describe "methods" do
    describe "set_period" do
      before do

        puts "NOW:"
        pp DateTime.now

        pm_shift
        
        pp pm_shift.end
        puts pm_shift.end.hour
        puts pm_shift.end.hour <= 18
        
        pp pm_shift.start
        puts pm_shift.start.hour
        puts pm_shift.start.hour >= 6
      end
      it "should set period correctly" do
        expect( pm_shift.period.text.upcase ).to eq 'PM'
      end  
    end    
  end
end