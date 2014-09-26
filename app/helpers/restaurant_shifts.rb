class RestaurantShifts
  attr_reader :arr, :start

  def initialize restaurants, start_t
    @start = start_t
    end_t = start_t + 1.week
    @arr = arr_from restaurants, start_t, end_t
  end

  def increment_week
    
  end

  private

    def arr_from restaurants, start_t, end_t
      #input: Arr of Riders, Datetiem, Datetime
      #output: Arr of Hashes of form:
        # [ { restaurant: Restaurant, shifts: [ Shift, Shift ] }, { restaurant: ... }, ... ]
      arr = []
      restaurants.sort_by{ |r| r.name }.each do |restaurant|
        arr.push( { 
          restaurant: restaurant, 
          shifts: restaurant.shifts_between( start_t, end_t ) 
        } )
      end
      arr
    end

end