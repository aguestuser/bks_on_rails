class Assignments
  attr_acessor :fresh, :with_conflicts, :with_double_bookings, :with_obstacles, :without_obstacles, :requiring_reassignment

  def initialize options
    fresh = options[:fresh] # Array of Assignments
    @with_conflicts =  options[:with_conflicts] || 
      fresh.select { |ass| ass.conflicts.any? } # Arr of Assignments
    @with_double_bookings =  options[:with_double_bookings] || 
      fresh.select { |ass| ass.double_bookings.any? } # Arr of Assignments
    
    @with_obstacles = options[:with_obstacles] || 
      with_conflicts.concat with_double_bookings #Arr of Assignments
    @without_obstacles = options[:without_obstacles] || 
      fresh.reject{ |ass| @with_obstacles.include? ass } #Arr of Assignments
    @requiring_reassignment = options[:without_obstacles] || [] #Arr of Assignments
  end 


  def resolve_obstacles_with decisions
    decisions.with_index do |decision, i| 
      if decision == :accept # move to @requiring_reassignment
        self.requiring_reassignment.push self.without_obstacles[i] 
        self.with_obstacles[i] = nil
      else # (if decision == :override) resolve obstacle and move to @without_obstacles
        assignment = self.with_obstacles[i].resolve_obstacle
        self.without_obstacles.push assignment
        self.with_obstacles[i] = nil
      end
    end
    assignments.with_obstacles.reject!(&:nil?)
    self
  end


end