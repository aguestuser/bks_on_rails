class Assignments
  include Hashable
  attr_accessor :fresh, :old, :with_conflicts, :with_double_bookings, :with_obstacles, :without_obstacles, :requiring_reassignment

  def initialize options
    @old = options[:old] || options[:fresh].clone # Array of Assignments 
    # NOTE: above will clone fresh options on first iteration, retain initial value of @old on subsequent (recursive) iterations
    @fresh = options[:fresh].each { |assignment| assignment.id = nil } || []# Array of Assignments
    # raise options[:fresh].inspect
    # raise ( "OLD ASSIGNMENTS: " + @old.inspect + "NEW ASSIGNMENTS: " + @fresh.inspect )

    @with_conflicts =  options[:with_conflicts] || [] # Arr of Assignments
    @with_double_bookings =  options[:with_double_bookings] || [] # Arr of Assignments
    @without_obstacles = options[:without_obstacles] || [] # Arr of Assignments
    @requiring_reassignment = options[:requiring_reassignment] || [] #Arr of Assignments
  end 

  def with_obstacles
    @with_conflicts + @with_double_bookings 
  end

  def find_obstacles
    #input: @fresh (implicit - must be loaded) Arr of Assignments
    #does: 
      # sorts assignments from fresh into 3 Arrays: 
        # (1) @with_conflicts: Arr of Assignments with conflicts
        # (2) @with_double_bookings: Arr of Assignmens with double bookings
        # (3) @without_obstacles: Arr of Assignments with neither conflicts nor double bookings 
      # clears @fresh
    # output: Assignments Obj
  
    @fresh.each do |assignment|
      if assignment.conflicts.any?
        @with_conflicts.push assignment
      elsif assignment.double_bookings.any?
        @with_double_bookings.push assignment
      else
        @without_obstacles.push assignment
      end
    end
    @fresh = []
    self
  end

  def resolve_obstacles_with decisions
    #input: @with_conflicts (implicit) Array of Assignments, @with_double_bookings (implicit) Array of Assignments
    #does: 
      # builds array of assignments with obstacles
      # based on user decisions, sorts them into either 
        # (1) assignments @requiring_reassignment
        # (2) assignments @without_obstacles (after clearing obstacles from assignment object)
      # clears @with_conflicts, @with_double_bookings, returns new state of Assignments Object
    with_obstacles = self.with_obstacles

    with_obstacles.each_with_index do |assignment, i|
      case decisions[i]
      when 'Accept' # move to @requiring_reassignment
        self.requiring_reassignment.push assignment 
      when 'Override' # resolve obstacle and move to @without_obstacles
        self.without_obstacles.push assignment.resolve_obstacle
      end      
    end 
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