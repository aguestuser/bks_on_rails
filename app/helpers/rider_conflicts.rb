class RiderConflicts
  attr_accessor :arr, :start

  def initialize riders, start_t
    @start = start_t
    end_t = start_t + 1.week 
    @arr = arr_from riders, start_t, end_t # Arr of Hashes
  end

  def increment_week
    #input: self (implicit)
    #does: increments the start and end time of every conflict by 1 week
    #output: self 
    self.arr.map do |rider_hash|
      { rider: rider_hash[:rider], conflicts: increment_week_for(rider_hash[:conflicts]) }
    end
    self
  end

  private

    def arr_from riders, start_t, end_t
      #input: Arr of Riders, Datetime, Datetime
      #output: Arr of Hashes of form:
        # [ { rider: Rider, conflicts: Arr of Conflicts}, ... ]
      riders.inject([]) do |arr, rider|
        arr.push( { rider: rider, conflicts: rider.conflicts_between(start_t, end_t) } )
        arr
      end
    end

    def increment_week_for conflicts
      conflicts.each { |c| c.increment_by 1.week }
    end

end