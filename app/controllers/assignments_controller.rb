class AssignmentsController < ApplicationController
  include Paths, Sortable

  # NOTE: always call through shift_assignment_path, NEVER call directly through assignment_path

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_assignment, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_base_path
  before_action :load_form_args, only: [ :edit, :update, :override_conflict, :override_double_booking ]

  def edit
  end

  def update
    # old_assignment = Assignment.new(@assignment.attributes)
    # @assignment.attributes = assignment_params
    new_assignment = Assignment.new(assignment_params)
    old_assignment = Assignment.find(new_assignment.id)
    assignments = Assignments.new( { 
      fresh: Assignments.wrap( [ new_assignment ] ),
      old: Assignments.wrap( [ old_assignment ] ) 
    } )
    get_savable assignments
  end

  def show
  end

  # def index
  # end

  def destroy
    @assignment.destroy
    flash[:success] = 'Assignment deleted'
    redirect_to @base_path
  end

  # def override_double_booking
  # end

  # def override_conflict
  # end

  def batch_edit
    @errors = []
    load_shift_batch # loads @shifts (Arr of Shifts)
    load_assignment_batch #loads @assignments (Assignments Obj)
      # puts ">>>>>> FROM BATCH EDIT:"
      # pp @assignments
    render 'batch_edit'
  end

  def batch_update
    assignments = Assignments.from_params params[:wrapped_assignments] # 
      # puts ">>>>>> FROM BATCH UPDATE:"
      # pp assignments
    get_savable assignments
  end

        def load_shift_batch
          @shifts = Shift.where("id IN (:ids)", { ids: params[:ids] } ).order(:start).to_a
        end

        def load_assignment_batch
          assignments = @shifts.map(&:assignment)
          wrapped_assignments = Assignments.wrap assignments
          @assignments = Assignments.new( { fresh: wrapped_assignments } )
        end


  def batch_edit_uniform
    @errors = []
    load_shift_batch # loads @shifts (Arr of Shifts)
    load_assignment_batch #loads @assignments (Assignments Obj)
      # puts ">>>>>> FROM BATCH EDIT UNIFORM:"
      # pp @assignments
    render 'batch_edit_uniform'
  end

  def batch_update_uniform
    assignments = Assignments.new( 
      { 
        fresh: new_uniform_assignments_from(params), 
        old: old_uniform_assignments_from(params)
      } 
    )
      # puts ">>>>>> FROM BATCH UPDATE UNIFORM:"
      # pp assignments
    get_savable assignments
  end

      def new_uniform_assignments_from params
        attrs = Assignment.attributes_from(params[:assignment]) # Hash
          # puts ">>>ATTRIBUTES"
          # pp attrs
        shift_ids = params[:shift_ids].map(&:to_i) # Array

        # attr_arr = shift_ids.inject([]){ |arr, id| arr.push( attrs.merge( { shift_id: id ) ) }
        # assignments = attr_arr.map{ |attrs| Assignment.new(attrs) }
        assignments = shift_ids.map do |shift_id| 
          attrs['shift_id'] = shift_id
          Assignment.new(attrs) 
        end
        Assignments.wrap(assignments)
      end

      def old_uniform_assignments_from params
        assignments = params[:shift_ids].map do |shift_id|
          attrs = Shift.find(shift_id).assignment.attributes #.reject{ |k,v| k == 'id'  }
          Assignment.new(attrs)
        end
        Assignments.wrap(assignments)
      end


  # def do_batch_update assignments
  #     # puts ">>>>>> FROM DO BATCH UPDATE:"
  #     # pp assignments
  #   get_savable assignments
  # end

  def get_savable assignments # RECURSION HOOK
    #input: Assignments Obj
    #output: Assignments Obj w/ empty .with_obstacles and .requiring_reassignment Arrays
      # puts ">>>>>> FROM GET SAVABLE (BEFORE FINDING OBSTACLES):"
      # pp assignments
    
    assignments = assignments.find_obstacles if assignments.fresh.any?

      # puts ">>>>>> FROM GET SAVABLE (AFTER FINDING OBSTACLES):"
      # pp assignments

    if assignments.with_obstacles.any?
      request_obstacle_decisions_for assignments # WILL RECURSE
      nil
    elsif assignments.requiring_reassignment.any?
      request_reassignments_for assignments # WILL RECURSE
      nil
    else # BASE CASE (BREAKS RECURSION)
      old_assignments = assignments.unwrap_old
      new_assignments = assignments.savable
    
      update_savable old_assignments, new_assignments
    end
  end

  # RECURSION CASE 1

  # def request_obstacle_decisions_for assignments

  def request_obstacle_decisions_for assignments
      # puts ">>>>>> FROM REQUEST OBSTACLE DECISIONS:"
      # pp assignments
    @assignments = assignments
    render "resolve_obstacles" # view posts to '/assignment/resolve_obstacles' 
  end

  def resolve_obstacles
    decisions = Assignments.decisions_from params[:decisions]
    assignments = Assignments.from_params( JSON.parse(params[:assignments_json] ) )
      # puts ">>>>>> FROM RESOLVE OBSTACLES (BEFORE RESOLVE):"
      # pp assignments
    assignments = assignments.resolve_obstacles_with decisions
      # puts ">>>>>> FROM RESOLVE OBSTACLES (AFTER RESOLVE):"
      # pp assignments
    get_savable assignments # RECURSE
  end


  # RECURSION CASE 2

  def request_reassignments_for assignments
      # puts ">>>>>> FROM REQUEST REASSIGNMENTS:"
      # pp assignments
    @errors = []
    @assignments = assignments
    render "batch_reassign" # view posts to '/assignment/batch_reassign'
  end

  def batch_reassign
      # puts ">>>>>>> PARAMS (from batch_reassign"
      # pp params
    assignments = Assignments.from_params params[:wrapped_assignments]
      # puts ">>>>>> FROM BATCH REASSIGN:"
      # pp assignments
    get_savable assignments # RECURSE
  end

  # SAVE ROUTINE

  def update_savable old_assignments, new_assignments
      # puts ">>>>>> FROM UPDATE SAVABLE"
      # puts "OLD ASSIGNMENTS:"
      # pp old_assignments
      # puts "NEW ASSIGNMENTS"
      # pp new_assignments
    now = Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now
    new_assignments.each{ |a| a.shift.refresh_urgency now } # will update weekly shifts to emergency and extra as appropriate

    if batch_save? old_assignments, new_assignments

      message = success_message_from old_assignments.count
      email_alert = send_batch_emails new_assignments, old_assignments, current_account
      
      flash[:success] = message << email_alert
      redirect_to @base_path
    else
      request_batch_error_fixes old_assignments, new_assignments
    end
  end

  def batch_save? old_assignments, new_assignments
    @errors = Assignment.batch_update(old_assignments, new_assignments)
    @errors.empty?
  end

  def success_message_from count
    if count > 1
      "Assignments successfully batch edited"
    else
      "Assignment successfully edited"
    end
  end

  def send_batch_emails new_assignments, old_assignments, current_account
    email_count = Assignment.send_emails new_assignments, old_assignments, current_account
    if email_count == 0 
      ""
    else 
      " -- #{email_count} emails sent"
    end
  end

  def request_batch_error_fixes old_assignments, new_assignments
    @assignments = Assignments.new({
      fresh: Assignments.wrap(new_assignments), 
    })
    render "batch_edit"
  end

  # HELPER

  def old_assignments_from new_assignments
    if params[:old_assignments_json]
      load_old_assignments
    else  
      new_assignments.map{ |ass| Assignment.find(ass.id) }
    end
  end

  def load_old_assignments
    Assignments.from_params JSON.parse(params[:old_assignments_json])
  end

  private 

    #CRUD HELPERS

    def load_shift
      @shift = Shift.find(params[:shift_id])
    end

    def load_assignment
      if params.include? :id
        @assignment = Assignment.find(params[:id])        
      elsif params.include? :shift_id
        @assignment = Assignment.where(shift_id: @shift.id)        
      else 
        raise "You tried to retrieve an assignment with no assignment id or shift id."
      end
    end

    def load_caller
      if params.include? :restaurant_id 
        @caller = :restaurant
        load_restaurant
      elsif params.include? :rider_id
        @caller = :rider
        load_rider
      else 
        @caller = nil
      end
    end

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end  

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    # BATCH CRUD HELPERS

    def parse_assignment_batch
      # input: Params (implicit)
      # output: Arr of Assignments
      @assignments = Assignment.where("id IN (:ids)", { ids: params[:assignments].map{ |a| a[:id] } } )
      # raise @assignments.inspect
    end  

    def parse_uniform_assignment_batch
      @assignments = Assignment.where("id IN (:ids)", { ids: params[:ids] })
    end


    # VIEW INTERACTION HELPERS

    def load_form_args
      case @caller
      when :restaurant
        @form_args = [ @restaurant, @shift, @assignment ]
      when :rider
        @form_args = [ @rider, @shift, @assignment ]
      when nil
        @form_args = [ @shift, @assignment ]
      end
    end 

    def assignment_params
      params
        .require(:assignment)
        .permit(:id, :rider_id, :shift_id, :status, :override_conflict, :override_double_booking)
    end

end
