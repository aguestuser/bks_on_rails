require 'spec_helper'
include RequestSpecMacros, ShiftRequestMacros, GridRequestMacros

describe "Grid Requests" do

  let(:staffer){ FactoryGirl.create(:staffer) }
  before { mock_sign_in staffer }

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
      end

      it { should have_h1('Shift Grid') }
      check_grid_filter_form_contents 

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
        expect( page.find( "#row_1_col_2" ).text ).to eq shift_grid_cell_text_for shifts[2]
        expect( page.find( "#row_1_col_7" ).text ).to eq ''
        expect( page.find( "#row_1_col_4" ).text ).to eq shift_grid_cell_text_for shifts[3]
        expect( page.find( "#row_1_col_9" ).text ).to eq ''
        expect( page.find( "#row_1_col_6" ).text ).to eq shift_grid_cell_text_for shifts[4]
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

    describe "double shift" do
      load_double_shift
      before do
        visit shift_grid_path
        select_first_week_of_2013 
      end

      it "should display double shift correctly" do
        expect( page.find( "#row_1_col_2" ).text ).to eq ( "DOUBLE: " << shift_grid_cell_text_for(double_shift) )
        expect( page.find( "#row_1_col_3" ).text ).to eq ( "DOUBLE: " << shift_grid_cell_text_for(double_shift) )
      end
    end
  end

  describe "Availability Grid" do
    load_shift_week_vars
    load_avail_grid_vars
    let!(:last_row){ Rider.all.count }
    subject { page }

    describe "contents" do

      before do 
        visit availability_grid_path
        select_first_week_of_2014
      end

      it { should have_h1('Availability Grid') }
      check_grid_filter_form_contents 

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
        expect( page.find( "#row_1_col_3" ).text ).to eq avail_grid_cell_text_for extra_shift
        expect( page.find( "#row_1_col_4" ).text ).to eq avail_grid_cell_text_for shifts[1]
        expect( page.find( "#row_1_col_5" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_1_col_2" ).text ).to eq avail_grid_cell_text_for shifts[2]
        expect( page.find( "#row_1_col_7" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_1_col_4" ).text ).to eq avail_grid_cell_text_for shifts[3]
        expect( page.find( "#row_1_col_9" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_1_col_6" ).text ).to eq avail_grid_cell_text_for shifts[4]
        expect( page.find( "#row_1_col_11" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_1_col_12" ).text ).to eq avail_grid_cell_text_for shifts[5]
        expect( page.find( "#row_1_col_13" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_1_col_14" ).text ).to eq avail_grid_cell_text_for shifts[6]
        expect( page.find( "#row_1_col_15" ).text ).to eq 'AVAIL'
      end

      it "should populate last row correctly" do
        expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq other_rider.name
        expect( page.find( "#row_#{last_row}_col_2" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_3" ).text ).to eq avail_grid_cell_text_for conflicts[0]
        expect( page.find( "#row_#{last_row}_col_4" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_5" ).text ).to eq avail_grid_cell_text_for conflicts[1]
        expect( page.find( "#row_#{last_row}_col_6" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_7" ).text ).to eq avail_grid_cell_text_for conflicts[2]
        expect( page.find( "#row_#{last_row}_col_8" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_9" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_10" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_11" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_12" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_13" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_14" ).text ).to eq 'AVAIL'
        expect( page.find( "#row_#{last_row}_col_15" ).text ).to eq 'AVAIL'
      end
    end # "page contents"

    describe "with OVERLAPPING CONFLICT & SHIFT" do
      let!(:conflict){ FactoryGirl.create(:conflict, :with_rider, rider: rider, start: monday + 11.hours, :end => monday + 16.hours  ) }
      before do 
        visit availability_grid_path
        select_first_week_of_2014
      end
      let(:cell){ page.find( '#row_1_col_2' ).text }

      it "should display conflict and shift in same cell" do
        expect(cell).to include '[NA]'
        expect(cell).to include restaurant.name
      end
    end # "with OVERLAPPING CONFLICT & SHIFT"

    # describe "with ASSIGNMENTS OF DIFFERING URGENCY" do
      
    # end

    describe "with DOUBLE CONFLICTS" do
      load_double_conflict
      before do 
        visit availability_grid_path
        select_first_week_of_2013
      end

      it "should display double conflict correctly" do
        expect( page.find( "#row_1_col_2" ).text ).to eq ( "DOUBLE: " << avail_grid_cell_text_for(double_conflict) )
        expect( page.find( "#row_1_col_3" ).text ).to eq ( "DOUBLE: " << avail_grid_cell_text_for(double_conflict) )
      end
    end # "with DOUBLE CONFLICTS"

    describe "links" do

      subject { current_path }
      
      describe "clicking on rider name" do
        before{ click_link(rider.name) }
        it { should eq rider_path(rider) }
      end

      describe "clicking on assignment" do
        before { click_link(avail_grid_cell_text_for(shifts[0]), match: :first ) }
        
        it { should include( shift_assignment_path( shifts[0], shifts[0].assignment ) ) }

        describe "saving edit" do
          before { click_button('Save changes') }

          it { should eq '/grid/availability' }
        end
      end

      describe "clicking on conflict" do
        before { click_link( avail_grid_cell_text_for(conflicts[0]), match: :first ) }
        
        it { should include(conflict_path(conflicts[0])) }

        describe "saving edit" do
          before { click_button('Save changes') }

          it { should eq '/grid/availability' }
        end
      end

      describe "clicking on 'AVAIL'" do
        before { click_link('AVAIL', match: :first) }
        it { should include(new_conflict_path) }

        describe "creating conflict" do
          before { click_button('Create conflict') }

          it { should eq '/grid/availability' }
        end        
      end
    end # "links"

    describe "SORTING" do

      describe "default sort" do
        it "should be rider, asc" do
          expect( page.find( "#row_1_col_1" ).text ).to eq rider.name
        end
      end

      describe "sorting by rider" do
        
        describe "ascending" do
          before do 
            click_link 'Rider'
            click_link 'Rider'
          end

          it "should sort rider to top and other_rider to bottom" do
            expect( page.find( "#row_1_col_1" ).text ).to eq rider.name
            expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq other_rider.name
          end
        end
        
        describe "descending" do
          before { click_link 'Rider' }

          it "should sort other_rider to top and rider to bottom" do
            expect( page.find( "#row_1_col_1" ).text ).to eq other_rider.name
            expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq rider.name
          end
        end
      end

      describe "sorting by period" do
        
        describe "ascending" do
          before { click_link 'Mon PM' }

          it "should sort rider to top and other_rider to bottom" do
            expect( page.find( "#row_1_col_1" ).text ).to eq rider.name
            expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq other_rider.name
          end
        end
        
        describe "descending" do
          before do 
            click_link 'Mon PM'
            click_link 'Mon PM'
          end

          it "should sort other_rider to top and rider to bottom" do
            expect( page.find( "#row_1_col_1" ).text ).to eq other_rider.name
            expect( page.find( "#row_#{last_row}_col_1" ).text ).to eq rider.name
          end
        end
      end       
    end # "SORTING"
  end
end