class RestaurantShifts
  attr_accessor :arr, :start

  def initialize restaurants, start_t
    @start = start_t
    end_t = start_t + 1.week
    @arr = arr_from restaurants, start_t, end_t
  end

  def increment_week
    self.arr.each do |hash|
      hash[:shifts] = hash[:shifts].map { |s| s.increment_by(1.week) } 
    end
    self
  end

  def save
    errors = []
    self.arr.each do |hash|
      subarray = []
      restaurant = hash[:restaurant]
      shifts = hash[:shifts]

      shifts.each do |shift|
        unless shift.save
          subarray.push({ error: shift.errors, record: shift })
        end
      end
      errors.push subarray if subarray.any?
    end
    errors
  end

  def self.from_params params
    rs = RestaurantShifts.new( [], Time.zone.parse( params[:week_start] ) )
    rs.arr = params[:restaurant_shifts].map do |rs_params|
      {
        restaurant: Restaurant.find( rs_params[:restaurant_id].to_i ),
        shifts: Shift.batch_from_params( rs_params[:shifts] )
      }
    end
    rs
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