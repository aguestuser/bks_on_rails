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

  def filter_shifts_by_time_inclusively
    #set start filter
    select '2011', from: 'filters_start_year'
    select 'January', from: 'filters_start_month'
    select '1', from: 'filters_start_day'
    #set end filter
    select '2017', from: 'filters_end_year'
    select 'January', from: 'filters_end_month'
    select '1', from: 'filters_end_day'
    
    click_button 'Filter'    
  end

  def filter_shifts_by_time_exclusively
    #set start filter
    select '2014', from: 'filters_start_year'
    select 'January', from: 'filters_start_month'
    select '1', from: 'filters_start_day'
    #set end filter
    select '2014', from: 'filters_start_year'
    select 'January', from: 'filters_start_month'
    select '2', from: 'filters_start_day'
    
    click_button 'Filter'    
  end

end