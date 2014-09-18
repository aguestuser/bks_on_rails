class RiderConflicts
  attr_reader :arr

  def initialize riders, start_t, end_t
    @arr = arr_from riders, start_t, end_t
  end

  private

    def arr_from riders, start_t, end_t
      all_conflicts( riders, start_t, end_t ).to_a
    end

    def all_conflicts riders, start_t, end_t
      riders.inject([]) do |arr, rider|
        arr.push( { rider: rider, conflicts: conflicts_for(rider, start_t, end_t) } )
        arr
      end
    end

    def conflicts_for rider, start_t, end_t
      conflicts = rider.conflicts
        .where(
          "start > :start AND start < :end",
          { start: start_t, :end => end_t }
        )
        .order("start asc")
      # puts ">>> conflicts for #{rider.name}"
      # pp conflicts

    end
end