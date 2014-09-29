class RestaurantShifts
  attr_accessor :arr, :start

  def initialize restaurants, start_t
    @start = start_t
    @end = start_t + 1.week
    @arr = arr_from restaurants, @start, @end
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
        
        if shift.starts_before @start
          shift.add_start_too_early_error @start
          subarray = record_error subarray, shift
        
        elsif shift.ends_after @end
          shift.add_end_too_late_error @end
          subarray = record_error subarray, shift
        
        else
          unless shift.save
            subarray = record_error subarray, shift
          end
        end
      end
      errors.push subarray
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

    def record_error subarray, shift
      subarray.push({ error: shift.errors, record: shift })
      subarray
    end

end