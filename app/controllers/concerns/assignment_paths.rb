class AssignmentPaths



    def assignment_path
      if @restaurant
        restaurant_shift_assignment_path(@restaurant, @shift, @shift.assignment)
      elsif @rider
        rider_shift_assignment_path(@rider, @shift, @shift.assignment)
      else 
        shift_assignment_path(@shift, @shift.assignment)
      end
    end

    def new_assignment_path
      if @restaurant
        new_restaurant_shift_assignment_path(@restaurant, @shift)
      elsif @rider
        new_rider_shift_assignment_path(@rider, @shift)
      else
        new_shift_assignment_path(@restaurant, @shift)
      end
    end

    def edit_assignment_path
      if @restaurant
        edit_restaurant_shift_assignment_path(@restaurant, @shift)
      elsif @rider
        edit_rider_shift_assignment_path(@rider, @shift)
      else
        edit_shift_assignment_path(@restaurant, @shift)
      end      
    end

    def edit(rider, shift)
      edit_restaurant_shift_assignment_path(restaurant, shift, shift.assignment)
    end

    def new(shift)
      new_restaurant_shift_assignment_path(restaurant, shift, shift.assignment)
    end
  when Rider
  
  else #when nil
    def show(shift)
    shift_assignment_path(shift, )
  end

end


