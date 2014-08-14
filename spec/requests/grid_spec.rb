require 'spec_helper'
include ShiftRequestMacros, GridRequestMacros

describe "Grid Requests" do

  describe "Shift Grid" do
    load_shift_week_vars
    # creates memoized local vars for: 
      # :monday, :sunday, 
      # :restaurant, :other_restaurant
      # :shifts, :other_shifts, :last_week_shift, :next_week_shift
    subject { page }

    describe "page contents" do
      before do
        visit shift_grid_path
        select_first_week_of_2014
        # puts page.find("/table/tr[2]/td[2]").text
      end

      it { should have_h1('Shift Grid') }
      
      describe "filter contents" do
        check_grid_filter_form_contents  
      end

      it "should populate header row correctly" do
        expect( page.find( "#row_0_col_1" ).text ).to eq 'Restaurant'
        expect( page.find( "#row_0_col_2" ).text ).to eq 'Mon AM'
        expect( page.find( "#row_0_col_3" ).text ).to eq 'Mon PM'
        expect( page.find( "#row_0_col_4" ).text ).to eq 'Tue AM'
        expect( page.find( "#row_0_col_5" ).text ).to eq 'Tue PM'
        expect( page.find( "#row_0_col_6" ).text ).to eq 'Wed AM'
        expect( page.find( "#row_0_col_7" ).text ).to eq 'Wed PM'
        expect( page.find( "#row_0_col_8" ).text ).to eq 'Thu AM'
        expect( page.find( "#row_0_col_9" ).text ).to eq 'Thu PM'
        expect( page.find( "#row_0_col_10" ).text ).to eq 'Fri AM'
        expect( page.find( "#row_0_col_11" ).text ).to eq 'Fri PM'
        expect( page.find( "#row_0_col_12" ).text ).to eq 'Sat AM'
        expect( page.find( "#row_0_col_13" ).text ).to eq 'Sat PM'
        expect( page.find( "#row_0_col_14" ).text ).to eq 'Sun AM'
        expect( page.find( "#row_0_col_15" ).text ).to eq 'Sun PM'
      end

      it "should populate first row correctly" do
        expect( page.find( "#row_1_col_1" ).text ).to eq restaurant.name
        expect( page.find( "#row_1_col_2" ).text ).to eq shift_grid_cell_text_for shifts[0]
        expect( page.find( "#row_1_col_3" ).text ).to eq ''
        expect( page.find( "#row_1_col_4" ).text ).to eq shift_grid_cell_text_for shifts[1]
        expect( page.find( "#row_1_col_5" ).text ).to eq ''
        expect( page.find( "#row_1_col_6" ).text ).to eq shift_grid_cell_text_for shifts[2]
        expect( page.find( "#row_1_col_7" ).text ).to eq ''
        expect( page.find( "#row_1_col_8" ).text ).to eq shift_grid_cell_text_for shifts[3]
        expect( page.find( "#row_1_col_9" ).text ).to eq ''
        expect( page.find( "#row_1_col_10" ).text ).to eq shift_grid_cell_text_for shifts[4]
        expect( page.find( "#row_1_col_11" ).text ).to eq ''
        expect( page.find( "#row_1_col_12" ).text ).to eq shift_grid_cell_text_for shifts[5]
        expect( page.find( "#row_1_col_13" ).text ).to eq ''
        expect( page.find( "#row_1_col_14" ).text ).to eq shift_grid_cell_text_for shifts[6]
        expect( page.find( "#row_1_col_15" ).text ).to eq ''
      end

      it "should populate second row correctly" do
        expect( page.find( "#row_2_col_1" ).text ).to eq other_restaurant.name
        expect( page.find( "#row_2_col_2" ).text ).to eq ''
        expect( page.find( "#row_2_col_3" ).text ).to eq shift_grid_cell_text_for other_shifts[0]
        expect( page.find( "#row_2_col_4" ).text ).to eq ''
        expect( page.find( "#row_2_col_5" ).text ).to eq shift_grid_cell_text_for other_shifts[1]
        expect( page.find( "#row_2_col_6" ).text ).to eq ''
        expect( page.find( "#row_2_col_7" ).text ).to eq shift_grid_cell_text_for other_shifts[2]
        expect( page.find( "#row_2_col_8" ).text ).to eq ''
        expect( page.find( "#row_2_col_9" ).text ).to eq ''
        expect( page.find( "#row_2_col_10" ).text ).to eq ''
        expect( page.find( "#row_2_col_11" ).text ).to eq ''
        expect( page.find( "#row_2_col_12" ).text ).to eq ''
        expect( page.find( "#row_2_col_13" ).text ).to eq ''
        expect( page.find( "#row_2_col_14" ).text ).to eq ''
        expect( page.find( "#row_2_col_15" ).text ).to eq ''
      end
    end
  end

  describe "Availability Grid" do
    load_avail_grid_vars
    before { configure_avail_grid_vars }

    describe "page contents" do
      before do
        visit availability_grid_path
        select_first_week_of_2014
        # last_row = Rider.all.count
        # pp page.find("#row_#{last_row}").text
      end

      let!(:last_row){ Rider.all.count }
      subject { page }

      it { should have_h1('Availability Grid') }

      describe "filter contents" do
        check_grid_filter_form_contents        
      end

      it "should populate header row correctly" do
        expect( page.find( "#row_0_col_1" ).text ).to eq 'Rider'
        expect( page.find( "#row_0_col_2" ).text ).to eq 'Mon AM'
        expect( page.find( "#row_0_col_3" ).text ).to eq 'Mon PM'
        expect( page.find( "#row_0_col_4" ).text ).to eq 'Tue AM'
        expect( page.find( "#row_0_col_5" ).text ).to eq 'Tue PM'
        expect( page.find( "#row_0_col_6" ).text ).to eq 'Wed AM'
        expect( page.find( "#row_0_col_7" ).text ).to eq 'Wed PM'
        expect( page.find( "#row_0_col_8" ).text ).to eq 'Thu AM'
        expect( page.find( "#row_0_col_9" ).text ).to eq 'Thu PM'
        expect( page.find( "#row_0_col_10" ).text ).to eq 'Fri AM'
        expect( page.find( "#row_0_col_11" ).text ).to eq 'Fri PM'
        expect( page.find( "#row_0_col_12" ).text ).to eq 'Sat AM'
        expect( page.find( "#row_0_col_13" ).text ).to eq 'Sat PM'
        expect( page.find( "#row_0_col_14" ).text ).to eq 'Sun AM'
        expect( page.find( "#row_0_col_15" ).text ).to eq 'Sun PM'
      end

      it "should populate first row correctly" do
        expect( page.find( "#row_1_col_1" ).text ).to eq rider.name
        expect( page.find( "#row_1_col_2" ).text ).to eq avail_grid_cell_text_for shifts[0]
        expect( page.find( "#row_1_col_3" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_4" ).text ).to eq avail_grid_cell_text_for shifts[1]
        expect( page.find( "#row_1_col_5" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_6" ).text ).to eq avail_grid_cell_text_for shifts[2]
        expect( page.find( "#row_1_col_7" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_8" ).text ).to eq avail_grid_cell_text_for shifts[3]
        expect( page.find( "#row_1_col_9" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_10" ).text ).to eq avail_grid_cell_text_for shifts[4]
        expect( page.find( "#row_1_col_11" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_12" ).text ).to eq avail_grid_cell_text_for shifts[5]
        expect( page.find( "#row_1_col_13" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_1_col_14" ).text ).to eq avail_grid_cell_text_for shifts[6]
        expect( page.find( "#row_1_col_15" ).text ).to eq '[AVAIL]'
      end

      it "should populate last row correctly" do
        expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq other_rider.name
        expect( page.find( "#row_#{last_row}_col_2" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_3" ).text ).to eq avail_grid_cell_text_for conflicts[0]
        expect( page.find( "#row_#{last_row}_col_4" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_5" ).text ).to eq avail_grid_cell_text_for conflicts[1]
        expect( page.find( "#row_#{last_row}_col_6" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_7" ).text ).to eq avail_grid_cell_text_for conflicts[2]
        expect( page.find( "#row_#{last_row}_col_8" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_9" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_10" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_11" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_12" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_13" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_14" ).text ).to eq '[AVAIL]'
        expect( page.find( "#row_#{last_row}_col_15" ).text ).to eq '[AVAIL]'
      end

    end
  end
end