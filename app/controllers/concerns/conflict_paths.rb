module ConflictPaths
  extend ActiveSupport::Concern

  included do 

    private

      def load_conflict_paths
        case @caller
        when :rider
          @conflict_paths = {
            index: rider_conflicts_path(@rider),
            conflict: lambda { |conflict| rider_conflict_path(@rider, conflict) },
            edit: lambda { |conflict| edit_rider_conflict_path(@rider, conflict) },
            :new => new_rider_conflict_path(@rider)
          }
        when nil
          @conflict_paths = {
            index: conflicts_path,
            conflict: lambda { |conflict| conflict_path(conflict) },
            edit: lambda { |conflict| edit_conflict_path(conflict) },
            :new => new_conflict_path
          }
        end
      end
  end
end