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

end