module GridRequestMacros
  def load_shift_week_vars
    let(:monday){ Time.zone.local(2014, 1, 6, 0) }
    let(:sunday){ monday + 6.days }

    let(:mini_contact){ FactoryGirl.create(:mini_contact, name: 'A'*10) }
    let(:other_mini_contact){ FactoryGirl.create(:mini_contact, name: 'z'*10) }

    let(:restaurant){ FactoryGirl.create(:restaurant, mini_contact: mini_contact) }
    let(:other_restaurant){ FactoryGirl.create(:restaurant, mini_contact: other_mini_contact) }

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
  end

  def select_first_week_of_2014
    #set start filter
    select '2014', from: 'filter_start_year'
    select 'January', from: 'filter_start_month'
    select '6', from: 'filter_start_day'
    
    click_button 'Filter'
  end

  def shift_grid_cell_text_for shift
    shift.assignment.rider.short_name.to_s << ' ' << shift.assignment.status.short_code
  end

  def load_avail_grid_vars
    let(:monday){ Time.zone.local(2014, 1, 6, 0) }
    let(:sunday){ monday + 6.days }

    let(:contact){ FactoryGirl.create(:contact, name: 'A'*10) }
    let(:other_contact){ FactoryGirl.create(:contact, name: 'z'*10) }
    
    let(:rider){ FactoryGirl.create(:rider, contact: contact) }
    let(:other_rider){ FactoryGirl.create(:rider, contact: other_contact) }

    let!(:shifts) do 
      7.times.map do |n|
        FactoryGirl.create(:shift, 
          :without_restaurant, 
          start: monday + n.days + 11.hours,
          :end => monday + n.days + 16.hours,
          assignment: Assignment.new(rider_id: rider.id) 
        )
      end
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
  end

  # def configure_avail_grid_vars
  #   shifts.each{ |s| s.assign_to rider }
  # end
end