class Assignments
  include Hashable
  attr_accessor :fresh, :old, :with_conflicts, :with_double_bookings, :with_obstacles, :without_obstacles, :requiring_reassignment

  def initialize options={}
    @old = options[:old] || options[:fresh].clone # Array of WrappedAssignments 
    # NOTE: above will clone fresh options on first iteration, retain initial value of @old on subsequent (recursive) iterations
    @fresh = options[:fresh] || [] # Array of WrapedAssignments
    # raise options[:fresh].inspect
    # raise ( "OLD ASSIGNMENTS: " + @old.inspect + "NEW ASSIGNMENTS: " + @fresh.inspect )

    @with_conflicts =  options[:with_conflicts] || [] # Arr of WrapedAssignments
    @with_double_bookings =  options[:with_double_bookings] || [] # Arr of WrapedAssignments
    @without_obstacles = options[:without_obstacles] || [] # Arr of WrapedAssignments
    @requiring_reassignment = options[:requiring_reassignment] || [] #Arr of WrapedAssignments
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

    @fresh.each do |wrapped_assignment|
      assignment = wrapped_assignment.assignment
      if assignment.conflicts.any?
        @with_conflicts.push wrapped_assignment
      elsif assignment.double_bookings.any?
        @with_double_bookings.push wrapped_assignment
      else
        @without_obstacles.push wrapped_assignment
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

    with_obstacles.each_with_index do |wrapped_assignment, i|
      case decisions[i]
      when 'Accept' # move to @requiring_reassignment
        self.requiring_reassignment.push wrapped_assignment 
      when 'Override' # resolve obstacle and move to @without_obstacles
        wrapped_assignment.assignment.resolve_obstacle
        self.without_obstacles.push wrapped_assignment
      end      
    end 
    self.with_conflicts = []
    self.with_double_bookings = []
    self
  end

  def savable
    #input: self (implicit) Assignments Obj, @without_obstacles (implicit) Array of WrappedAssignments
    #does: restores Arr of WrappedAssignments without obstacles to original sort and returns unwrapped Arr of Assignments
    #output: Array of Assignments
    savable = @without_obstacles.sort_by{ |wrapped_assignment| wrapped_assignment.index }
    savable.map(&:assignment)
  end

  def unwrap_old
    #input: self (implicit), @old (implicit) Array of WrappedAssignments
    #output: Array of Assignments
    @old.map(&:assignment)
  end

  # def to_params
  #   self.to_json.to_query 'assignments'
  # end

  # CLASS METHODS

  def Assignments.wrap assignments
    assignments.each_with_index.map { |assignment, i| WrappedAssignment.new(assignment, i) }
  end

  def Assignments.wrap_with_indexes assignments, indexes
    assignments.each_with_index.map { |assignment, i| WrappedAssignment.new(assignment, indexes[i]) } 
  end

  def Assignments.from_params params
    #input Hash of type
      # { 'fresh': [
      #     {
      #       id: Num,
      #       assignment:{
      #         'id': Num,
      #         'rider_id': Num,
      #         'shift_id': Num,
      #         ...(other Assignment attributes)
      #       }
      #     }     
      #    'id': Num
      #    ],
      #   'old': [
      #     {
      #       'id': Num,
      #       'assignment':{
      #         ...(Assignment attributes)...
      #       }
      #     }
      #   ].... (other Arrays of WrappedAssignment attributes)   
      # }
    #does: parses params hash into WrappedAssignments that can be passed as options to initialize an Assignments object
    #output: Assignments Obj

    options = {}
    params.each do |key, wrapped_attr_arr|
      index_arr = wrapped_attr_arr.map{ |wrapped_attrs| wrapped_attrs['index'] }
      attr_arr = wrapped_attr_arr.map{ |wrapped_attrs| wrapped_attrs['assignment'] }
      assignments = attr_arr.map{ |attrs| Assignment.new(attrs) }

      options[key.to_sym] = Assignments.wrap_with_indexes assignments, index_arr
    end
    Assignments.new(options)
  end

  def Assignments.decisions_from params
    #input params[:decisions] (must be present)
    decisions = []
    params.each { |k,v| decisions[k.to_i] = v }
    decisions
  end

  class WrappedAssignment
    attr_accessor :assignment, :index

    def initialize assignment, index
      @assignment = assignment
      @index = index
    end
  end
end