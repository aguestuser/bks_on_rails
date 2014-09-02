class RiderShifts
  attr_reader :array

  def initialize assignments
    @array = array_from assignments
  end

  private

    def array_from assignments
      #input: Arr of assignments
      #output: Arr of Hashes of form:
        # [ { rider: <Rider>, shifts: [<Arr of Shifts>], restaurants: [<Arr of Restaurants>] } ]
      arr = []
      assignments.each do |a|
        arr = add_rider_slot_if_none a, arr
        rider_hash = rider_hash_from a, arr
        
        rider_hash = add_restaurant_if_none a, rider_hash
        rider_hash[:shifts].push(a.shift)

        # index = arr.index(rider_hash)
        # arr = add_restaurant_if_none a, arr, index
        # arr[index][:shifts].push(a.shift)
      end
      arr
    end

    def rider_hash_from a, arr
      arr.find { |arr_el| arr_el[:rider] == a.rider }
    end

    def add_rider_slot_if_none a, arr
      if new_rider_slot? a, arr
        new_rider_slot_from a, arr
      else
        arr
      end
    end

    def new_rider_slot? a, arr
      if arr.empty? 
        true
      elsif arr.find{ |rider_hash| rider_hash[:rider] == a.rider }
        false 
      else 
        true
      end
    end

    def new_rider_slot_from a, arr
      arr.push({ rider: a.rider, shifts: [], restaurants: []})
    end

    # def add_restaurant_if_none a, arr, index
    def add_restaurant_if_none a, rider_hash    
      # arr[index][:restaurants].push(a.shift.restaurant) if new_restaurant_slot? a, arr[index]
      rider_hash[:restaurants].push(a.shift.restaurant) if new_restaurant_slot? a, rider_hash
      rider_hash
      # arr
    end

    def new_restaurant_slot? a, rider_hash
      !rider_hash[:restaurants].include? a.shift.restaurant
    end


end