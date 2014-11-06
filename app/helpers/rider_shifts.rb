class RiderShifts
  attr_reader :hash
  URGENCIES = [ :emergency, :extra, :weekly ]
  EMAIL_TYPES = [ :delegation, :confirmation ]

  def initialize assignments
    @hash = hash_from assignments
  end

  private

    def hash_from assignments
      #input: Arr of assignments
      #output: Hash of Hashes of type:
        # { Num <rider_id>: 
        #   { rider: Rider, 
        #     extra: {
        #       delegation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       },
        #       confirmation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       }
        #     },
        #     emergency: {
        #       delegation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       },
        #       confirmation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       }
        #     },    
        #     weekly: {
        #       delegation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       },
        #       confirmation: {
        #         shifts: Arr of Shifts,
        #         restaurants: Arr of Restaurants
        #       }
        #     },       
        #   } 
        # }
      grouped_by_rider = group_by_rider assignments
      with_parsed_rider_and_shift = parse_rider_and_shifts grouped_by_rider
      grouped_by_urgency = group_by_urgency with_parsed_rider_and_shift
      grouped_by_email_type = group_by_email_type grouped_by_urgency
      sorted_by_date = sort_by_date grouped_by_email_type
      with_restaurants = insert_restaurants sorted_by_date
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
          # { rider: Rider, emergency: Arr of Shifts, extra: Arr of Shifts, weekly: Arr of Shifts } 
        # }
      hash = {}
      assignments.each do |id, rider_hash|
        grouped = rider_hash[:shifts].group_by{ |s| s.urgency.text.downcase.to_sym }
        hash[id] = { rider: rider_hash[:rider] }
        URGENCIES.each { |urgency| hash[id][urgency] = grouped[urgency] || [] }
      end
      hash
    end

    def group_by_email_type assignments
      #input Hash of Hashes of type
        # { Num<rider_id>: 
        #   { rider: Rider, emergency: Arr of Shifts, extra: Arr of Shifts, weekly: Arr of Shifts } 
        # }
      #output: Hash of Hashes of type
        # { Num <rider_id>: 
        #   { rider: Rider, 
        #     extra: {
        #       delegation: Arr of Shifts,
        #       confirmation: Arr of Shifts
        #     },
        #     emergency: {
        #       delegation: Arr of Shifts,
        #       confirmation: Arr of Shifts
        #     },    
        #     weekly: {
        #       delegation: Arr of Shifts,
        #       confirmation: Arr of Shifts
        #     }       
        #   } 
        # }
        hash = {}
        assignments.each do |id, rider_hash|
          hash[id] = { rider: rider_hash[:rider] }
          URGENCIES.each do |urgency|
            hash[id][urgency] = {}
            grouped = rider_hash[urgency].group_by { |s| s.assignment.status.text.downcase.sub('delegated', 'delegation').sub('confirmed', 'confirmation').to_sym }
            EMAIL_TYPES.each do |email_type| 
              hash[id][urgency][email_type] = grouped[email_type] || [] 
            end
          end
        end
        hash
    end

    def sort_by_date assignments
      hash = assignments.clone
      hash.each do |id, rider_hash|
        URGENCIES.each do |urgency|
          EMAIL_TYPES.each do |email_type|
            rider_hash[urgency][email_type].sort_by!{ |shift| shift.start } if rider_hash[urgency][email_type]
          end
        end
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
        hash[id] = { rider: rider_hash[:rider] }
        URGENCIES.each do |urgency|
          hash[id][urgency] = {}
          EMAIL_TYPES.each do |email_type|
            shifts = rider_hash[urgency][email_type] || []
            restaurants = parse_restaurants shifts
            hash[id][urgency][email_type] = { shifts: shifts , restaurants: restaurants }
          end
        end
      end
      hash
    end

    def parse_restaurants shifts
      shifts.map{ |shift| shift.restaurant }.uniq
    end

end