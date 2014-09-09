class RiderShifts
  attr_reader :array

  def initialize assignments
    @array = array_from assignments
  end

  private

    # def array_from assignments
    #   #input: Arr of assignments
    #   #output: Arr of Hashes of form:
    #     # [ { rider: <Rider>, shifts: [<Arr of Shifts>], restaurants: [<Arr of Restaurants>] } ]
    #   arr = []
    #   grouped_by_rider = group_by_rider assignments


    #   assignments.each do |a|

    #     arr = add_rider_slot_if_none a, arr
    #     rider_hash = rider_hash_from a, arr
        
    #     rider_hash = add_restaurant_if_none a, rider_hash
    #     rider_hash[:shifts].push(a.shift)

    #     # index = arr.index(rider_hash)
    #     # arr = add_restaurant_if_none a, arr, index
    #     # arr[index][:shifts].push(a.shift)
    #   end
    #   arr
    # end

    def array_from assignments
      #input: Arr of assignments
            #output: Hash of Hashes of type:
        # { Num<rider_id>: 
          # { rider: Rider, 
            # emergency_ shifts: {
              # shifts: Arr of Shifts, 
              # restaurants: Arr of Restaurants
            # }
            # extra_shifts: {
              # shifts: Arr of Shifts 
              # restaurants: Arr of Restaurants
            # } 
        # }
      grouped_by_rider = group_by_rider assignments
      with_parsed_rider_and_shift = parse_rider_and_shifts assignments
      grouped_by_urgency = group_by_urgency grouped_by_rider
      with_restaurants = insert_restaurants grouped_by_urgency
    end

    def group_by_rider assignments
      #input: Array of type: [ Assignment, Assignment, ...]
      #output: Hash of type: { Num(rider_id): Arr of Assignments }
      assignments.group_by{ |a| a.rider.id }
    end

    def parse_rider_and_shifts assignments
      #input: Hash of type: { Num(rider_id): Arr of Assignments }
      #output: Hash of Hashes of type: { Num<rider_id>: { rider: Rider, shifts: Arr of Shifts } }
      hash = {}
      assignments.each do |id,assignments|
        hash[id] = { rider: assignments.first.rider, shifts: assignments.map(&:shift) }
      end
      hash
    end

    def group_by_urgency assignments
      #input: Hash of Hashes of type: { Num<rider_id>: { rider: Rider, shifts: Arr of Shifts } }
      #output: Hash of Hashes of type: 
        # { Num<rider_id>: 
          # { rider: Rider, emergency: Arr of Shifts, extra: Arr of Shifts } 
        # }
      hash = {}
      assignments.each do |id, rider_hash|
        sorted_hash = rider_hash[:shifts].group_by{ |s| s.urgency }
        hash[id] = { 
          rider: rider_hash[:rider], 
          emergency: sorted_hash[:emergency], 
          extra: sorted_hash[:extra] 
        }
      end
      hash
    end

    def insert_restaurants assignments
      #input: Hash of Hashes of type: 
        # { Num<rider_id>: 
          # { rider: Rider, emergency: Arr of Shifts, extra: Arr of Shifts } 
        # }
      #output: Hash of Hashes of type:
        # { Num<rider_id>: 
          # { rider: Rider, 
            # emergency_ shifts: {
              # shifts: Arr of Shifts, 
              # restaurants: Arr of Restaurants
            # }
            # extra_shifts: {
              # shifts: Arr of Shifts 
              # restaurants: Arr of Restaurants
            # } 
        # }
      hash = {}
      assignments.each do |id, rider_hash|
        hash[id] = {
          rider: rider_hash[:rider],
          emergency: urgency_hash(rider_hash[:emergency], parse_restaurants(rider_hash[:emergency]),
          extra: urgency_hash(rider_hash[:extra], parse_restaurants(rider_hash[:extra]))
        }
      hash
      end
    end

    def parse_restaurants shifts
      shifts.map{ |shift| shift.restaurant }.uniq
    end

    def urgency_hash shifts, restaurants
      { shifts: shifts, restaurants: restaurants }
    end

    def group_by_urgency assignments
      assignments
    end

    # def rider_hash_from a, arr
    #   arr.find { |arr_el| arr_el[:rider] == a.rider }
    # end

    # def add_rider_slot_if_none a, arr
    #   if new_rider_slot? a, arr
    #     new_rider_slot_from a, arr
    #   else
    #     arr
    #   end
    # end

    # def new_rider_slot? a, arr
    #   if arr.empty? 
    #     true
    #   elsif arr.find{ |rider_hash| rider_hash[:rider] == a.rider }
    #     false 
    #   else 
    #     true
    #   end
    # end

    # def new_rider_slot_from a, arr
    #   arr.push({ rider: a.rider, shifts: [], restaurants: []})
    # end

    # # def add_restaurant_if_none a, arr, index
    # def add_restaurant_if_none a, rider_hash    
    #   # arr[index][:restaurants].push(a.shift.restaurant) if new_restaurant_slot? a, arr[index]
    #   rider_hash[:restaurants].push(a.shift.restaurant) if new_restaurant_slot? a, rider_hash
    #   rider_hash
    #   # arr
    # end

    # def new_restaurant_slot? a, rider_hash
    #   !rider_hash[:restaurants].include? a.shift.restaurant
    # end


end