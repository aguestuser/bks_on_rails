require 'spec_helper'
include ValidationMacros

describe Week do
  let(:monday){ Time.zone.local(2014, 1, 6, 0) }
  let(:sunday){ monday + 6.days }

  let(:restaurant){ FactoryGirl.create(:restaurant) }
  let(:other_restaurant){ FactoryGirl.create(:restaurant) }

  let!(:shifts) do
    7.times.map do |n|
      FactoryGirl.create(:shift, 
        :with_restaurant, 
        restaurant: restaurant, 
        start: monday + n.days + 11.hours,
        :end => monday + n.days + 16.hours 
      )
    end
  end
  let!(:other_shifts) do
    3.times.map do |n|
      FactoryGirl.create(:shift, 
        :with_restaurant, 
        restaurant: other_restaurant, 
        start: monday + n.days +  18.hours,
        :end => monday + n.days + 23.hours
      )
    end
  end
  let!(:last_week_shift) do
    FactoryGirl.create(:shift, 
      :with_restaurant, 
      restaurant: other_restaurant, 
      start: monday - 1.day +  11.hours,
      :end => monday - 1.day + 16.hours
    )
  end
  let!(:next_week_shift) do
    FactoryGirl.create(:shift, 
      :with_restaurant, 
      restaurant: other_restaurant, 
      start: sunday + 1.day +  11.hours,
      :end => sunday + 1.day + 16.hours
    )
  end

  let(:shift_week){ Week.new( monday, sunday, Shift ) }

  subject {shift_week}

  describe "attributes" do
    let(:attrs){ [:start, :end, :klass, :records, :record_hash] }
    it "should respond to all attributes" do
      check_attributes shift_week, attrs
    end
  end

  describe "methods" do
    
    it "should respond to all public methods" do
      check_attributes shift_week, [ :records_for ]
    end
    
    it "should not respond to private methods" do
      check_private_methods shift_week, [ :load_records, :load_record_hash ]
    end

    describe "load_records" do
      let(:records){ shift_week.records }
      # before{ records.each{ |r| pp r } }

      it "should retrieve records of correct type" do
        expect( records.map(&:class) ).to eq records.map{ Shift }
      end

      it "should order records correctly" do
        expect( records.first.start < records.last.start ).to eq true
        expect( records[0].start <= records[1].start ).to eq true
        expect( records[-2].start <= records[-1].start ).to eq true
      end

      it "should only include shifts within correct date range" do
        expect( records.include? last_week_shift ).to eq false
        expect( records.first.start < monday ).to eq false
        expect( records.include? next_week_shift ).to eq false
        expect( records.last.start > sunday + 24.hours ).to eq false
      end

      it "should have correct number of records" do
        expect( records.count ).to eq shifts.count + other_shifts.count
      end
    end

    describe "load_record_hash" do
      let(:record_hash){ shift_week.record_hash }
      let(:am_values) { record_hash.select { |k,v| k.to_s.include?('am') && !v.nil? }.values.map(&:first) }
      let(:pm_values) { record_hash.select { |k,v| k.to_s.include?('pm') && !v.nil? }.values.map(&:first) }
      # before do
      #   puts "RECORDS:"
      #   pp shift_week.records
      #   puts 'RECORD_HASH:'
      #   pp record_hash
      # end

      it "should have keys for each period" do
        expect( record_hash.keys.count ).to eq 14
      end

      it "should have values for each shift" do
        expect( record_hash.values.select{|v| !v.empty? }.count ).to eq 10
      end

      describe "key/value pairs" do
        
        it "should put AM shifts in AM k/v pairs" do
          expect( am_values.count ).to eq 7
          expect( am_values.map(&:period).map(&:text).map(&:upcase) ).to eq am_values.map{ 'AM' }
        end

        it "should put PM shifts in PM k/v pairs" do
          expect( pm_values.count ).to eq 3
          expect( pm_values.map(&:period).map(&:text).map(&:upcase) ).to eq pm_values.map{ 'PM' }
        end
      end
      
      describe "records_for" do
        let(:restaurant_mon_am_shifts){ shift_week.records_for 'mon_am', restaurant: restaurant }
        let(:restaurant_sun_am_shifts){ shift_week.records_for 'sun_am', restaurant: restaurant }
        let(:restaurant_mon_pm_shifts){ shift_week.records_for 'mon_pm', restaurant: restaurant }
        
        let(:other_restaurant_mon_pm_shifts){ shift_week.records_for 'mon_pm', restaurant: other_restaurant }
        let(:other_restaurant_wed_pm_shifts){ shift_week.records_for 'wed_pm', restaurant: other_restaurant }
        let(:other_restaurant_mon_am_shifts){ shift_week.records_for 'mon_am', restaurant: other_restaurant }

        it "should retrieve records correctly" do
          expect( restaurant_mon_am_shifts.count ).to eq 1
          expect( restaurant_mon_am_shifts.first ).to eq shifts.first
          expect( restaurant_sun_am_shifts.count ).to eq 1
          expect( restaurant_sun_am_shifts.first ).to eq shifts.last
          expect( restaurant_mon_pm_shifts ).to eq []

          expect( other_restaurant_mon_pm_shifts.count ).to eq 1
          expect( other_restaurant_mon_pm_shifts.first ).to eq other_shifts.first
          expect( other_restaurant_wed_pm_shifts.count ).to eq 1
          expect( other_restaurant_wed_pm_shifts.first ).to eq other_shifts.last
          expect( other_restaurant_mon_am_shifts ).to eq []
        end
      end
    end
  end
end