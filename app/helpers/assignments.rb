class Assignments
  include Hashable
  attr_accessor :fresh, :old, :with_conflicts, :with_double_bookings, :with_obstacles, :without_obstacles, :requiring_reassignment

  def initialize options
    # raise options[:fresh].inspect
    @old = options[:old] || options[:fresh].clone # Array of Assignments 
    # -> (set to same value of fresh on first iteration of recursion, retains value therafter) 
    @fresh = options[:fresh].each { |ass| ass.id = nil } || []# Array of Assignments
    # raise ( "OLD ASSIGNMENTS: " + @old.inspect + "NEW ASSIGNMENTS: " + @fresh.inspect )
    

    @with_conflicts =  options[:with_conflicts] || 
      @fresh.select { |ass| ass.conflicts.any? } # Arr of Assignments
    @with_double_bookings =  options[:with_double_bookings] || 
      @fresh.select { |ass| ass.double_bookings.any? } # Arr of Assignments
    @with_obstacles = options[:with_obstacles] || 
      (@with_conflicts + @with_double_bookings) #Arr of Assignments
    @without_obstacles = options[:without_obstacles] || 
      @fresh.reject{ |ass| @with_obstacles.include? ass } #Arr of Assignments
    @requiring_reassignment = options[:requiring_reassignment] || [] #Arr of Assignments
  end 

  def resolve_obstacles_with decisions

    decisions.each_with_index do |decision, i| 
      case decision
      when 'Accept' # move to @requiring_reassignment
        self.requiring_reassignment.push self.with_obstacles[i] 
      when 'Override' # resolve obstacle and move to @without_obstacles
        self.without_obstacles.push self.with_obstacles[i].resolve_obstacle
      end
    end
    self.with_obstacles = []
    self.with_conflicts = []
    self.with_double_bookings = []
    self
  end

  #to_params

  def to_params
    self.to_json.to_query 'assignments'
    # self.instance_values.to_query 'assignments'
  end

  def Assignments.from_params params
    #input Hash of type
    # { 'fresh': [ Arr of Hashes of type:
      # { 'id' =>, 'shift_id' = > num}, etc...
    # raise params.inspect
    options = {}
    params.each do |key, ass_arr|
      options[key.to_sym] = ass_arr.map do |ass_attrs|
        Assignment.new(ass_attrs)
      end
    end
    Assignments.new(options)
  end

  def Assignments.from_id_params id_params
    # input: Hash of type
      # { 
      #   'fresh' => [Arr of Strs (ids)], 
      #   'with_conflicts' => [Arr of Strs (ids)], 
      #   'with_double_bookings' => [Arr of Strs (ids)], 
      #   'with_obstacles' => [Arr of Strs (ids)], 
      #   'without_obstacles' => [Arr of Strs (ids)],  
      #   'requiring_reassignment' => [Arr of Strs (ids)],                        
      # }
    # does: parses 
    # output: 
    options = {}
    id_params.each do |key, ids|
      options[key.to_sym] = ids.map do |id|
        Assignment.find(id.to_i) 
      end
    end
    Assignments.new(options)      
  end

  def Assignments.decisions_from params
    #input params[:decisions]
    decisions = []
    params.each { |k,v| decisions[k.to_i] = v }
    decisions
  end
end