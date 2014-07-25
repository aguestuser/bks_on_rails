module ShiftPaths
  extend ActiveSupport::Concern

  included do
    
    private

      def load_shift_paths
        case @caller
        when :restaurant
          @shift_paths = {
            shift: lambda { |shift| restaurant_shift_path(@restaurant, shift) },
            edit_shift: lambda { |shift| edit_restaurant_shift_path(@restaurant, shift) },
            new_shift: new_restaurant_shift_path(@restaurant),
            index: restaurant_shifts_path(@restaurant),
            assignment: lambda { |shift, assignment| restaurant_shift_assignment_path(@restaurant, shift, assignment) },
            edit_assignment: lambda { |shift, assignment| edit_restaurant_shift_assignment_path(@restaurant, shift, assignment) },
            new_assignment: lambda { |shift| new_restaurant_shift_assignment_path(@restaurant, shift) }
          }
        when :rider
          @shift_paths = {
            shift: lambda { |shift| rider_shift_path(@rider, shift) },
            edit_shift: lambda { |shift| edit_rider_shift_path(@rider, shift) },
            new_shift: new_rider_shift_path(@rider),
            index: rider_shifts_path(@rider),
            assignment: lambda { |shift, assignment| rider_shift_assignment_path(@rider, shift, assignment) },
            edit_assignment: lambda { |shift, assignment| edit_rider_shift_assignment_path(@rider, shift, assignment) },
            new_assignment: lambda { |shift| new_rider_shift_assignment_path(@rider, shift) }
          }
        else #when nil
          @shift_paths = {
            shift: lambda { |shift| shift_path(shift) },
            edit_shift: lambda { |shift| edit_shift_path(shift) },
            new_shift: new_shift_path,
            index: shifts_path,
            assignment: lambda { |shift, assignment| shift_assignment_path(shift, assignment) },
            edit_assignment: lambda { |shift, assignment| edit_shift_assignment_path(shift, assignment) },
            new_assignment: lambda { |shift| new_shift_assignment_path(shift) }          
          }
        end
    end
  end
end