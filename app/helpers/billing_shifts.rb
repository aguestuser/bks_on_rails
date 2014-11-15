module BillingShifts

  def resolve shifts
    shifts = set_free shifts
    shifts = set_extra shifts
    shifts.each(&:save) # ?
    shifts
  end

  def set_free shifts
    should_be_free = shifts.select do |s| 
      status = s.assignment.status.text
      status == 'Unassigned' || status == 'Cancelled (Rider)'
    end
  end

  def set_extra shifts
    grouped_shifts = group shifts
    grouped_shifts.each do |rest, day_hash|
      day_hash.each do |day, per_hash|
        per_hash.each do |per, shifts|
          resolve_extra shifts
        end
      end
    end
  end


  def group shifts
    # temp_grouped_by_rest = shifts.group_by{|s| s.restaurant}
    # grouped_by_rest = temp_grouped_by_rest.keys.map{ |key| temp_grouped_by_rest[key] }
    # THAT! ABOVE!

    # [ Proc.new{ |s| s.restaurant},
    #   Proc.new{ |s| s.start.day},
    #   Proc.new{ |s| s.period}  
    # ].map do |proc|

    # end

    # grouped_by_rest = shifts.group_by{|s| s.restaurant}.to_a

    # grouped_by_day = grouped_by_rest.map{ |rest_group| rest_group[1].group_by{ |s| s.start.day } }

    # grouped_by_per = grouped_by_day.map{ |day_group|  }

    grouped = procs.inject([]) do |arr, proc|
      proc.call( arr )
    end

    ########how to recursively describe the below pattern?

    grouped_by_rest = arrayify shifts.group_by{|s| s.restaurant}

    puts "gropued by rest"
    pp grouped_by_rest

    grouped_by_day = grouped_by_rest.map{ |rest_group| arrayify rest_group.group_by { |s| s.start.day } }

    puts "grouped by day"
    pp grouped_by_day

    grouped_by_per = grouped_by_day.map { |day_group| day_group.map{ |rest_group| arrayify rest_group.group_by { |s| s.period } } }
    # call change_billings on the innermost array of shifts here (the one produced by arrayify rest_group.group_by...)

    puts "grouped by period"
    pp grouped_by_per
  end

  def arrayify hash
    hash.keys.map{ |key| hash[key] }
  end

  def change_billing shifts
    # takes array of shifts and:
    # (1) makes all unassigned/cancelled shifts free
    # (2) for shift arrays with length > 1
    #     (a) 
  end

  def resolve_extra shifts
    #input
  end

end