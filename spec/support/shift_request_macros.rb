module ShiftRequestMacros

  def load_riders_and_restaurants
    let!(:restaurant) { FactoryGirl.create(:restaurant) }
    let!(:other_restaurant) { FactoryGirl.create(:restaurant) }
    let!(:rider){ FactoryGirl.create(:rider) }
    let!(:other_rider){ FactoryGirl.create(:rider) }
  end

  def load_batch
    let(:start_t){ Time.zone.local(2014,1,6,12) }
    let(:end_t){ Time.zone.local(2014,1,6,18) }
    let!(:batch)do
      3.times.map do |n|
        FactoryGirl.build(:shift, :with_restaurant, restaurant: restaurant, start: start_t + n.days, :end => end_t + n.days)
      end
    end
  end

  def load_conflicts
    let(:conflicts) do 
      3.times.map do |n| 
        FactoryGirl.build(:conflict, :with_rider, rider: other_rider, start: batch[n].start, :end => batch[n].end)
      end
    end
  end

  def load_double_bookings
    let(:double_bookings) do 
      3.times.map do |n|
        FactoryGirl.build(:shift, :with_restaurant, restaurant: restaurant, start: batch[n].start, :end => batch[n].end)
      end
    end
  end

  def load_free_rider
    let!(:free_rider){ FactoryGirl.create(:rider) }
  end

  def load_this_week_shifts
    let!(:restaurants){ 3.times.map{ FactoryGirl.create(:restaurant) } }
    let!(:this_week_shifts) do
      r1_shifts = 7.times.map do |n|
        FactoryGirl.create( :shift, :with_restaurant, restaurant: restaurants[0], start: start_t + n.days, :end => end_t + n.days )
      end
      r2_shifts = 7.times.map do |n|
        FactoryGirl.create( :shift, :with_restaurant, restaurant: restaurants[1], start: start_t + n.days, :end => end_t + n.days )
      end

      r1_shifts + r2_shifts
    end
  end

  def load_next_week_shifts
    let!(:next_week_shifts) do
      this_week_shifts.map do |shift|
        shift.increment_by 1.week
      end
    end
    let(:next_start_t){ start_t + 1.week }
    let(:next_end_t){ end_t + 1.week }
  end

  def check_shift_form_contents(path)
    expect(page).to have_label('Start')
    expect(page).to have_label('End')
    expect(page).to have_label('Urgency')
    expect(page).to have_label('Billing')
    expect(page).to have_label('Notes')
    case path
    when 'root'
      expect(page).to have_label('Restaurant')
    when 'restaurant'
      expect(page).not_to have_label('Restaurant')
    end
  end

  def check_batch_shift_selects
    expect(page).to have_select("shifts[][restaurant_id]")
    expect(page).to have_select("shifts[][urgency]")
    expect(page).to have_select("shifts[][billing_rate]")
    expect(page).to have_select("shifts[][start][year]")
    expect(page).to have_select("shifts[][start][month]")
    expect(page).to have_select("shifts[][start][day]")
    expect(page).to have_select("shifts[][start][hour]")
    expect(page).to have_select("shifts[][start][minute]")
    expect(page).to have_select("shifts[][end][year]")
    expect(page).to have_select("shifts[][end][month]")
    expect(page).to have_select("shifts[][end][day]")
    expect(page).to have_select("shifts[][end][hour]")
    expect(page).to have_select("shifts[][end][minute]")
  end

  def make_base_shift
    select batch[0].restaurant.name, from: "shifts[][restaurant_id]"
    select batch[0].urgency.text , from: "shifts[][urgency]" 
    select batch[0].billing_rate.text , from: "shifts[][billing_rate]" 
    select '2014' , from: "shifts[][start][year]" 
    select 'January' , from: "shifts[][start][month]" 
    select '6' , from: "shifts[][start][day]" 
    select '12 PM', from: "shifts[][start][hour]" 
    select '00' , from: "shifts[][start][minute]" 
    select '2014' , from: "shifts[][end][year]" 
    select 'January' , from: "shifts[][end][month]" 
    select '6' , from: "shifts[][end][day]" 
    select '6 PM', from: "shifts[][end][hour]" 
    select '00' , from: "shifts[][end][minute]"  
    select 3, from: "num_shifts"
    click_button 'Clone'
  end

  def make_invalid_shift_submission
    select '09 AM', from: 'shift_start_4i'
    select '08 AM', from: 'shift_end_4i'
    click_button submit       
  end

  def make_valid_shift_submission
    select restaurant.name, from: 'shift_restaurant_id'
    select '08 AM', from: 'shift_start_4i'
    select '09 AM', from: 'shift_end_4i'
    click_button submit    
  end

  def configure_shifts_for_sort_tests
    #configure first shift
    first_shift.restaurant.mini_contact.update(name: 'A'*10)
    rider.contact.update(name: 'A'*10)
    first_shift.assign_to rider
    first_shift.assignment.update(status: :cancelled_by_restaurant)
    #configure second shift
    second_shift.restaurant.mini_contact.name = 'z'*10
    second_shift.restaurant.mini_contact.save
    second_shift.unassign
    #initialize dummy shift
    dummy_shift
  end

  def filter_shifts_by_time_inclusively options={}
    #set start filter
    select '2011', from: 'filter_start_year'
    select 'January', from: 'filter_start_month'
    select '1', from: 'filter_start_day'
    #set end filter
    select '2017', from: 'filter_end_year'
    select 'January', from: 'filter_end_month'
    select '1', from: 'filter_end_day'
    
    click_button 'Filter' unless options[:block_click]  
  end

  def filter_shifts_by_time_exclusively
    #set start filter
    select '2014', from: 'filter_start_year'
    select 'January', from: 'filter_start_month'
    select '1', from: 'filter_start_day'
    #set end filter
    select '2014', from: 'filter_end_year'
    select 'January', from: 'filter_end_month'
    select '2', from: 'filter_end_day'
    
    click_button 'Filter'    
  end

  def filter_shifts_by_restaurant restaurants, options={}
    Restaurant.all.each { |r| unselect r.name, from: 'filter_restaurants' }
    unselect '* All Restaurants', from: 'filter_restaurants'
    restaurants.each { |r| select r.name, from: 'filter_restaurants' }
    click_button 'Filter' unless options[:block_click]
  end

  def filter_shifts_by_rider riders, options={}
    id = 'filter_riders'
    # clear multiselect
    Rider.all.each { |r| unselect r.name, from: id }
    unselect '* All Riders', from: 'filter_riders'
    unselect '--', from: 'filter_riders' 
    # make new selections
    riders.each do |r|
      if r.nil?
        select '--', from: 'filter_riders'
      else
        select r.name, from: 'filter_riders'
      end
    end
    #submit
    click_button 'Filter' unless options[:block_click]
  end

  def filter_shifts_by_status status_strs, options={}
    id = 'filter_status'
    #clear multiselect
    AssignmentStatus.select_options.map(&:first).each do |status|
      unselect status, from: id
    end
    unselect '* All Statuses', from: 'filter_status'
    #make new selections
    status_strs.each { |status| select status, from: id }
    #submit
    click_button 'Filter' unless options[:block_click]
  end

  def batch_assign_first_shift
    page.within("#row_1"){ check "ids[]" }
    click_button 'Batch Assign', match: :first
    click_button 'Save changes'
  end

  def check_original_filters_retained
    expect(selected_riders).to include first_shift.rider.id.to_s
    expect(selected_riders).not_to include "all"
    expect(selected_restaurants).to include first_shift.restaurant.id.to_s
    expect(selected_restaurants).not_to include "all"
    expect(selected_status).to include first_shift.assignment.status.text
    expect(selected_status).not_to include "* All Statuses"
    expect(selected_start_month).to eq "1"
    expect(selected_end_month).to eq "1"    
  end

  def check_batch_assign_uri
    expect(current_path).to eq "/assignment/batch_edit"
    expect(URI.parse(current_url).to_s).to include("&ids[]=#{batch[0].id}&ids[]=#{batch[1].id}&ids[]=#{batch[2].id}")
  end

  def check_uniform_assign_uri
    expect(current_path).to eq "/assignment/batch_edit_uniform"
    expect(URI.parse(current_url).to_s).to include("&ids[]=#{batch[0].id}&ids[]=#{batch[1].id}&ids[]=#{batch[2].id}")
  end

  def check_batch_assign_select_values rider, status
    rider_id_selector = "#wrapped_assignments_fresh__assignment_rider_id"
    status_selector = "#wrapped_assignments_fresh__assignment_status"

    expect(page.within("#assignments_fresh_0"){ find(rider_id_selector).find("option[selected]").text }).to eq rider.name
    expect(page.within("#assignments_fresh_1"){ find(rider_id_selector).find("option[selected]").text }).to eq rider.name
    expect(page.within("#assignments_fresh_2"){ find(rider_id_selector).find("option[selected]").text }).to eq rider.name
    
    expect(page.within("#assignments_fresh_0"){ find(status_selector).find("option[selected]").text }).to eq status
    expect(page.within("#assignments_fresh_1"){ find(status_selector).find("option[selected]").text }).to eq status
    expect(page.within("#assignments_fresh_2"){ find(status_selector).find("option[selected]").text }).to eq status    
  end

  def assign_batch_to rider, status
    3.times do |n|
      page.within("#assignments_fresh_#{n}") do 
        find("#wrapped_assignments_fresh__assignment_rider_id").select rider.name
        find("#wrapped_assignments_fresh__assignment_status").select status
      end
    end
    click_button 'Save changes'
  end

  def check_uniform_assign_shift_list rider, status
    expect(page.within("#shifts"){ find("h3").text }).to eq "Shifts"

    expect(page.all("#shifts_0 .shift_box")[0].text).to eq "#{batch[0].table_time} @ #{restaurant.name}"
    expect(page.all("#shifts_0 .shift_box")[1].text).to eq "Assigned to: #{rider.name} [#{status}]"

    expect(page.all("#shifts_1 .shift_box")[0].text).to eq "#{batch[1].table_time} @ #{restaurant.name}"
    expect(page.all("#shifts_1 .shift_box")[1].text).to eq "Assigned to: #{rider.name} [#{status}]"

    expect(page.all("#shifts_2 .shift_box")[0].text).to eq "#{batch[2].table_time} @ #{restaurant.name}"
    expect(page.all("#shifts_2 .shift_box")[1].text).to eq "Assigned to: #{rider.name} [#{status}]"
  end

  def check_uniform_assign_select_values
    expect(page.within("#assignment_form"){ find("#assignment_rider_id").has_css?("option[selected]") } ).to eq false
    expect(page.within("#assignment_form"){ find("#assignment_status").find("option[selected]").text }).to eq 'Proposed'
  end

  def uniform_assign_batch_to rider, status
    page.find("#assignment_rider_id").select rider.name
    page.find("#assignment_status").select status
    click_button 'Save changes'
  end
  
  def check_assignments_with_conflicts_list conflict_list_indices, batch_indices
    expect(page.within("#assignments_with_conflicts"){ find("h3").text }).to eq "Assignments With Conflicts"
    conflict_list_indices.each_with_index do |i,j|
      batch_index = batch_indices[j]
      expect(page.all("#assignments_with_conflicts_#{i} .shift_box")[0].text).to eq "#{batch[batch_index].table_time} @ #{batch[batch_index].restaurant.name}"
      expect(page.all("#assignments_with_conflicts_#{i} .shift_box")[1].text).to eq "Assigned to: #{other_rider.name} [Proposed]"
      expect(page.all("#assignments_with_conflicts_#{i} .shift_box")[2].text).to eq conflicts[batch_index].table_time
      expect(page.find("#decisions_#{i}_Accept")).to be_checked
      expect(page.find("#decisions_#{i}_Override")).to_not be_checked      
    end
  end

  def check_assignments_with_double_booking_list double_booking_list_indices, batch_indices
    expect(page.within("#assignments_with_double_bookings"){ find("h3").text }).to eq "Assignments With Double Bookings"
    double_booking_list_indices.each_with_index do |i,j|
      batch_index = batch_indices[j]
      expect(page.all("#assignments_with_double_bookings_#{i} .shift_box")[0].text).to eq "#{batch[batch_index].table_time} @ #{batch[batch_index].restaurant.name}"
      expect(page.all("#assignments_with_double_bookings_#{i} .shift_box")[1].text).to eq "Assigned to: #{other_rider.name} [Proposed]"
      expect(page.all("#assignments_with_double_bookings_#{i} .shift_box")[2].text).to eq "#{double_bookings[batch_index].table_time} @ #{double_bookings[batch_index].restaurant.name}"
      expect(page.find("#decisions_0_Accept")).to be_checked
      expect(page.find("#decisions_0_Override")).to_not be_checked      
    end
  end


  def check_without_obstacles_list list_indices, batch_indices
    #input: Array of Nums (indices of assignments_without_obstacles Arr to check for), Array of Nums (indices of batch Shifts Arr to retrieve values from)
    expect(page.within("#assignments_without_obstacles"){ find("h3").text }).to eq "Assignments Without Obstacles"
    list_indices.each_with_index do |i,j|
      batch_index = batch_indices[j]
      expect(page.all("#assignments_without_obstacles_#{i} .shift_box")[0].text).to eq "#{batch[batch_index].table_time} @ #{restaurant.name}"
      expect(page.all("#assignments_without_obstacles_#{i} .shift_box")[1].text).to eq "Assigned to: #{other_rider.name} [Proposed]"      
    end
  end

  def check_reassign_single_shift_list rider, status, batch_index
    expect(page.within("#assignments_requiring_reassignment"){ find("h3").text }).to eq "Assignments Requiring Reassignment"
    expect(page.find("#assignments_requiring_reassignment_0 .shift_box").text).to eq "#{batch[batch_index].table_time} @ #{batch[batch_index].restaurant.name}"
    expect(page.within("#assignments_requiring_reassignment_0"){ 
        find("#wrapped_assignments_fresh__assignment_rider_id").find("option[selected]").text 
      }).to eq rider.name
    expect(page.within("#assignments_requiring_reassignment_0"){ 
        find("#wrapped_assignments_fresh__assignment_status").find("option[selected]").text 
      }).to eq status
  end

  def reassign_single_shift_to rider, status
    page.within("#assignments_requiring_reassignment_0") { find("#wrapped_assignments_fresh__assignment_rider_id").select rider.name }
    page.within("#assignments_requiring_reassignment_0") { find("#wrapped_assignments_fresh__assignment_status").select status }
    click_button 'Save changes'
  end

  def check_reassigned_shift_values rider, status
    expect(page.find("#row_1_col_4").text).to eq rider.name
    expect(page.find("#row_2_col_4").text).to eq rider.name
    expect(page.find("#row_3_col_4").text).to eq rider.name

    expect(page.find("#row_1_col_5").text).to eq status
    expect(page.find("#row_2_col_5").text).to eq status
    expect(page.find("#row_3_col_5").text).to eq status
  end

  def check_reassigned_shift_values_after_accepting_obstacle rider_1, rider_2, status
    names = [
      page.find("#row_1_col_4").text,
      page.find("#row_2_col_4").text,
      page.find("#row_3_col_4").text
    ]

    expect(names).to include rider_2.name

    # expect(page.find("#row_1_col_4").text).to eq rider_2.name
    # expect(page.find("#row_2_col_4").text).to eq rider_1.name
    # expect(page.find("#row_3_col_4").text).to eq rider_1.name

    expect(page.find("#row_1_col_5").text).to eq status
    expect(page.find("#row_2_col_5").text).to eq status
    expect(page.find("#row_3_col_5").text).to eq status
  end

  def select_batch_assign_shifts_from_grid
    page.within("#row_1_col_2"){ find("#ids_").set true }
    page.within("#row_1_col_4"){ find("#ids_").set true }
    page.within("#row_1_col_6"){ find("#ids_").set true }   
  end

  def check_reassigned_shift_values_in_grid rider, status_code
    expect(page.find("#row_1_col_2").text).to eq "#{rider.short_name} #{status_code}"
    expect(page.find("#row_1_col_4").text).to eq "#{rider.short_name} #{status_code}"
    expect(page.find("#row_1_col_6").text).to eq "#{rider.short_name} #{status_code}"     
  end

  def check_clone_week_fields restaurants, lengths, shifts
    #input: Arr of Restaurants, Arr of Ints, Arr of Shifts
    restaurants.each_with_index do |restaurant, i|
      
      expect(page).to have_h3("#{restaurant.name}")
      
      lengths[i].times do |j|
        shift = shifts[j].increment_by 1.week

        expect( 
          Time.zone.parse(
            page.find("#restaurant_#{i} #shift_#{j} #restaurant_shifts__shifts__start").value
          )
        ).to eq shift.start
        expect( 
          Time.zone.parse(
            page.find("#restaurant_#{i} #shift_#{j} #restaurant_shifts__shifts__end").value
          )
        ).to eq shift.end
      end
    end
  end

  def check_cloned_shift_values shifts, expected_shifts
    expect( 
      shifts.map { |s| filter_cloned s.attributes  }
    ).to eq expected_shifts.map{ |s| filter_cloned s.attributes }
  end

  def filter_cloned attrs
    attrs.reject{ |k,v| not_cloned? k }
  end

  def not_cloned? key
    key == 'id' || key == 'notes' || key == 'created_at' || key == 'updated_at'
  end

  def expected_new_shifts action
    case action
    when :add
      expected_add_shifts
    when :remove
      expected_remove_shifts
    when :edit
      expected_edit_shifts
    end
  end

  def expected_add_shifts
    next_week_shifts + 2.times.map { #shifts[7] }
      FactoryGirl.create(:shift, :with_restaurant, restaurant: restaurants[1], start: next_start_t, :end => next_end_t )
    }
  end

  def expected_remove_shifts
    next_week_shifts[0..6] + next_week_shifts[8..12]
  end

  def expected_edit_shifts
    edited_shifts = next_week_shifts.clone
    2.times { |i| edited_shifts[i] = edited_shifts[i].increment_by -2.hours }
    edited_shifts
  end

  def check_point_review_row shift, i
    expect(page.find("#row_#{i+1}_col_1").text).to eq shift.restaurant.name
    expect(page.find("#row_#{i+1}_col_2").text).to eq shift.review_points_time
    expect(page.find("#row_#{i+1}_col_3").text).to eq shift.billing_rate.text
    expect(page.find("#row_#{i+1}_col_4").text).to eq shift.urgency.text
    expect(page.find("#row_#{i+1}_col_5").text).to eq shift.assignment.rider.name
    expect(page.find("#row_#{i+1}_col_6").text).to eq shift.assignment.status.text
    expect(page.find("#row_#{i+1}_col_7").text).to eq shift.assignment.notes    
  end

  
end