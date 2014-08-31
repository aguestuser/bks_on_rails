module ShiftRequestMacros

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
    select '1' , from: "shifts[][start][day]" 
    select '12 PM', from: "shifts[][start][hour]" 
    select '00' , from: "shifts[][start][minute]" 
    select '2014' , from: "shifts[][end][year]" 
    select 'January' , from: "shifts[][end][month]" 
    select '1' , from: "shifts[][end][day]" 
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

  def filter_shifts_by_time_inclusively
    #set start filter
    select '2011', from: 'filter_start_year'
    select 'January', from: 'filter_start_month'
    select '1', from: 'filter_start_day'
    #set end filter
    select '2017', from: 'filter_end_year'
    select 'January', from: 'filter_end_month'
    select '1', from: 'filter_end_day'
    
    click_button 'Filter'    
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

  def filter_shifts_by_restaurant restaurants
    Restaurant.all.each { |r| unselect r.name, from: 'filter_restaurants' }
    restaurants.each { |r| select r.name, from: 'filter_restaurants' }
    click_button 'Filter'
  end

  def filter_shifts_by_rider riders
    id = 'filter_riders'
    # clear multiselect
    Rider.all.each { |r| unselect r.name, from: id }
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
    click_button 'Filter'
  end

  def filter_shifts_by_status status_strs
    id = 'filter_status'
    #clear multiselect
    AssignmentStatus.select_options.map(&:first).each do |status|
      unselect status, from: id
    end
    #make new selections
    status_strs.each { |status| select status, from: id }
    #submit
    click_button 'Filter'
  end

  def check_batch_assign_uri
    expect(current_path).to eq "/shift/batch_edit"
    expect(URI.parse(current_url).to_s).to include("&ids[]=#{batch[0].id}&ids[]=#{batch[1].id}&ids[]=#{batch[2].id}&commit=Batch+Assign")
  end

  def check_batch_assign_select_values
    expect(page.all("#assignments__rider_id")[0].find('option[selected]').text).to eq batch[0].rider.name
    expect(page.all("#assignments__rider_id")[1].find('option[selected]').text).to eq batch[1].rider.name
    expect(page.all("#assignments__rider_id")[2].find('option[selected]').text).to eq batch[2].rider.name

    expect(page.all("#assignments__status")[0].find('option[selected]').text).to eq batch[0].assignment.status.text
    expect(page.all("#assignments__status")[1].find('option[selected]').text).to eq batch[1].assignment.status.text
    expect(page.all("#assignments__status")[2].find('option[selected]').text).to eq batch[2].assignment.status.text
  end

end