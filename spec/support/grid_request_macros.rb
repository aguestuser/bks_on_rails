module GridRequestMacros
  def load_shift_week_vars
    let(:monday){ Time.zone.local(2014, 1, 6, 0) }
    let(:sunday){ monday + 6.days }

    let!(:restaurant){ FactoryGirl.create(:restaurant) }
    let!(:other_restaurant){ FactoryGirl.create(:restaurant) }

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

    before do 
      restaurant.mini_contact.update(name: 'A'*10)
      other_restaurant.mini_contact.update(name: 'z'*10)
    end
  end

  def load_double_shift
    let!(:double_shift){
      FactoryGirl.create(:shift,
        :without_restaurant,
        start: Time.zone.local(2013,1,7,10),
        :end => Time.zone.local(2013,1,7,20)
      )
    }
  end

  def select_first_week_of_2013
    fill_in "filter[start]", with: "January 7, 2013"
    click_button 'Filter'
  end

  def select_first_week_of_2014
    fill_in "filter[start]", with: "January 6, 2014"
    click_button 'Filter'
  end

  def shift_grid_cell_text_for shift
    shift.assignment.rider.short_name.to_s << ' ' << shift.assignment.status.short_code
  end

  def load_avail_grid_vars
    load_shift_week_vars

    let!(:rider){ FactoryGirl.create(:rider) }
    let!(:other_rider){ FactoryGirl.create(:rider) }

    let!(:extra_shift) do
      FactoryGirl.create(:shift, 
        :with_restaurant, 
        restaurant: restaurant, 
        start: monday +  18.hours,
        :end => monday + 23.hours
      )
    end
    let!(:conflicts) do
      3.times.map do |n|
        FactoryGirl.create(:conflict,
          :with_rider, 
          rider: other_rider, 
          start: monday + n.days +  18.hours,
          :end => monday + n.days + 23.hours
        )
      end
    end

    before do
      shifts.each { |s| s.assign_to rider }
      other_shifts.each { |s| s.unassign }
      extra_shift.assign_to rider
      rider.contact.update(name: 'A'*10)
      other_rider.contact.update(name: 'z'*10)
    end
  end

  def load_double_conflict
    let!(:double_conflict){
      FactoryGirl.create(:conflict,
        :with_rider,
        rider: rider,
        start: Time.zone.local(2013,1,7,10),
        :end => Time.zone.local(2013,1,7,20)
      )
    }
  end

  def configure_avail_grid_vars
    shifts.each { |s| s.assign_to rider }
    extra_shift.assign_to rider
    rider.contact.update(name: 'A'*10)
    other_rider.contact.update(name: 'z'*10)
    # restaurant.mini_contact.update(name: 'A'*10)
  end

  def check_grid_filter_form_contents
    it { should have_label('Start:') }
    it { should have_field('filter[start]')}
    it { should have_content('End:') }
    it { should have_content(shifts[6].formal_date) }
  end

  def avail_grid_cell_text_for record
    case record.class.name
    when 'Shift'
      record.restaurant.name + ' ' + record.assignment.status.short_code
    when 'Conflict'
      "[NA] #{record.grid_time}"
    end
  end

  def filter_grid_for_jan_2014
    fill_in 'filter_start', with: 'January 6, 2014'
    click_button 'Filter'
  end


end