class AssignmentsController < ApplicationController
  include Paths, Sortable

  # NOTE: always call through shift_assignment_path, NEVER call directly through assignment_path

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_assignment, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_base_path
  before_action :load_form_args, only: [ :edit, :update, :override_conflict, :override_double_booking ]
  
  before_action :redirect_to_rider_shifts, only: [ :new, :create ]

  def new
    @assignment = Assignment.new
    load_form_args
    # @assignment.shift = @shift      
  end

  def create
    @assignment = Assignment.new(assignment_params)
    load_form_args
    attempt_save_from :create
  end

  def edit
  end

  def update
    # input: assignment
    # does: (1) tests if are save obstacles
      #if so: redirects to obstacle override page
      #if not: (2) tests if save errors
        #if so: redirects to edit page showing errors
        #if not: redirects to base page with success message
    #side effects: saves if can save
    #output: redirect action
    old_assignment = Assignment.new(@assignment.attributes)
    @assignment.attributes = assignment_params

    case @assignment.save_obstacles
    when :none
      if assignment.save
        email_sent = assignment.try_send_email old_assignment, current_user
        email_alert = email_sent ? " -- Email sent to rider" : ""
        flash[:success] = assignment.save_success_message + email_alert
      else
        render 'edit'
      end
    when :double_booking
      @override_subject = :double_booking
      @back_path = @base_path
      render 'override_double_booking'
    when :conflict
      @override_subject = :conflict
      @back_path = @base_path
      render 'override_conflict'
    end
  end

  def show
  end

  def index
  end

  def destroy
    @assignment.destroy
    flash[:success] = 'Assignment deleted'
    redirect_to @base_path
  end

  def override_double_booking
  end

  def override_conflict
  end

  def batch_edit
    @errors = []
    load_shift_batch # loads @shifts
    load_assignment_batch #loads @assignments
    render 'batch_edit'
  end

  def batch_edit_uniform
    @errors = []
    load_shift_batch
    load_assignment_batch
    render 'batch_edit_uniform'
  end



  def batch_update
    do_batch_update new_assignments_from(params)
    # old_assignments = old_assignments_from params
    # new_assignments = new_assignments_from params

    # do_batch_update old_assignments, new_assignments
  end


      # def old_assignments_from params
      #   Assignment.where("id IN (:ids)", { ids: params[:assignments].map{ |ass| ass[:id] } } ).to_a
      # end

      def new_assignments_from params
        attr_arr = params[:assignments].map{ |param_hash| Assignment.attributes_from param_hash }
        attr_arr.map{ |attrs| Assignment.new(attrs) }
      end 

  def batch_update_uniform
    do_batch_update new_uniform_assignments_from(params)
    # old_assignments = old_uniform_assignments_from params
    # new_assignments = new_uniform_assignments_from params
    
    # do_batch_update old_assignments, new_assignments
  end

      # def old_uniform_assignments_from params
      #   Assignment.where("id IN (:ids)", { ids: params[:ids] })
      # end

      def new_uniform_assignments_from params
        ids = params[:ids].map(&:to_i)
        attrs = Assignment.attributes_from(params[:assignment])
        ids.map do |id| 
          attrs['shift_id'] = id
          Assignment.new(attrs) 
        end
      end


  def do_batch_update new_assignments
    get_savable Assignments.new( { fresh: new_assignments } )
  end

      def get_savable assignments # RECURSION HOOK
        #input: Assignments Obj
        #output: Assignments Obj w/ empty .with_obstacles and .requiring_reassignment Arrays
        if assignments.with_obstacles.any?
          request_obstacle_decisions_for assignments # will recurse
          nil
        elsif assignments.requiring_reassignment.any?
          request_reassignments_for assignments # will recurse
          nil
        else # BASE CASE (BREAKS RECURSION)
          new_assignments = assignments.without_obstacles
          old_assignments = new_assignments.map{ |ass| Assignment.find(ass.id) }
          update_savable old_assignments, new_assignments
          # try_saving assignments.without_obstacles
        end
      end

      def update_savable old_assignments, new_assignments
        if batch_save? old_assignments, new_assignments
          email_alert = send_batch_emails new_assignments, old_assignments, current_account
          flash[:success] = "Assignments successfully batch edited" << email_alert
          redirect_to @base_path
        else
          request_batch_error_fixes savable_assignments
        end
      end

      # RECURSION CASE 1

      # def request_obstacle_decisions_for assignments

      def request_obstacle_decisions_for assignments
        @assignments = assignments
        # params[:base_path] = @base_path
        render "resolve_obstacles"
        # view posts to '/assignment/resolve_obstacles' 
        # all assignments are uneditable, user has choice to accept or override each obstacle
      end

      def resolve_obstacles
        decisions = Assignments.decisions_from params[:decisions]
        assignments = Assignments.from_params JSON.parse(params[:assignments_json])
        assignments = assignments.resolve_obstacles_with decisions

        get_savable assignments # RECURSE
      end


      # RECURSION CASE 2

      def request_reassignments_for assignments
        @assignments = assignments
        render "batch_reassign"
        # view posts to '/assignment/reassign_batch'
      end

      def batch_reassign
        assignments = Assignments.from_params params[:assignments]
        get_savable assignments # RECURSE
      end

      # SAVE ROUTINE

      def batch_save? old_assignments, new_assignments
        @errors = Assignment.batch_update(old_assignments, new_assignments)
        @errors.empty?
      end

      def request_batch_error_fixes assignments
        @assignments = assignments
        render "batch_edit"
      end

      def send_batch_emails assignments, old_assignments, current_account
        email_count = Assignment.send_emails assignments, old_assignments, current_account
        if email_count == 0 
          ""
        else 
          " -- #{email_count} emails sent"
        end
      end

      # def parse_obstacle_decisions assignments, decisions
      #   decisions.with_index do |decision, i| 
      #     if decision == :accept
      #       assignments.requiring_edit.push assignments.without_obstacles[i] 
      #     else # if decision == :override
      #       assignment = assignments_with_obstacles[i].resolve_obstacle_with decision
      #       assignments.without_obstacles.push assignment
      #     end
      #   end
      #   assignments.with_obstacles = []
      #   assignments
      # end

        # def assignments_from_assignments_params assignments_params
        #   raise assignments_params.inspect

        #   assignments_params.each do |key, ass_param_arr|

        #   end
        #   options[:fresh] = assignments_params.map do |param_hash|
        #       attrs = Assignment.attributes_from param_hash
        #       Assignment.new(attrs)
        #     end
        #   Assignments.new(options)
        # end

      # def parse_batch_query
      #   params.extract!(:base_path).to_query
      #   # { base_path: @base_path }.to_query
      # end

        # def assignments_from_id_params id_hash
        #   options = assignments_options_from id_hash
        #   Assignments.new(options)
        # end

        # def assignments_options_from id_hash
        #   # input: Hash of type
        #     # { 
        #     #   'fresh' => [Arr of Strs (ids)], 
        #     #   'with_conflicts' => [Arr of Strs (ids)], 
        #     #   'with_double_bookings' => [Arr of Strs (ids)], 
        #     #   'with_obstacles' => [Arr of Strs (ids)], 
        #     #   'without_obstacles' => [Arr of Strs (ids)],  
        #     #   'requiring_reassignment' => [Arr of Strs (ids)],                        
        #     # }
        #   # does: parses 
        #   # output: 
        #   options = {}
        #   id_hash.each do |key, ids|
        #     options[key.to_sym] = ids.map do |id|
        #       Assignment.find(id.to_i) 
        #     end
        #   end
        #   options          
        # end

    # def batch_update
  #   old_assignments = parse_old_assignments
  #   new_assignments = parse_new_assignments

  #   parse_assignment_batch # loads @assignments

  #   do_batch_update params[:assignments]
  # end

  # def batch_update_uniform
  #   parse_uniform_assignment_batch # loads @assignments
  #   assignment_attrs = @assignments.count.times.map{ params[:assignment] }
    
  #   do_batch_update assignment_attrs
  # end

  # def do_batch_update assignment_attrs
  #   # input: Arr of Assignments
  #   # does: (1) tests if are save obstacles for any Assignments
  #     #if so (for ANY assignment): redirects to obstacle override page for that assignment
  #     #if not (for ALL assignments): (2) tests if save errors
  #       #if so: redirects to edit page showing errors
  #       #if not: redirects to base page with success message
  #   #side effects: saves if can save
  #   #output: redirect action
  #   old_assignments = @assignments.map { |a| Assignment.new(a.attributes) }
  #   if no_batch_save_obstacles? @assignments
  #     if successful_batch_save
  #       email_alert = try_send_batch_emails assignments, old_assignments, current_account
  #       flash[:success] = "Assignments successfully batch edited" << email_alert
  #       redirect_to @base_path
  #     else
  #       render "assignments/batch_edit"
  #     end
  #   end
  # end

  def no_batch_save_obstacles? assignments
    if assignments.count == 0 # BASE CASE
      false
    else
      assignments.each_with_index do |assignment, i| # RECURSION LOOP
        case assignment.save_obstacles
        when :none
          find_obstacles assignments[ (i+1)..assignments.count ] # CALL RECURSION LOOP (SKIP AHEAD)
        when :conflict
          # handle_batch_conflict assignment
          find_obstacles assignments[i..assignments.length] # CALL RECURSION LOOP (AT SAME INDEX)
        when :double_booking
          # handle_batch_double_booking assignment
          find_obstacles assignments[i..assignments.length] # CALL RECURSION LOOP (AT SAME INDEX)
        end
      end
    end
  end

  def handle_batch_conflict assignment
    @assignment = assignment
    @override_subject = :conflict
    query = { 
      ids: ids_from_batch_conflict(params),
      base_path: params[:base_path]
    }.to_query
    @back_path = "/assignments/batch_edit?#{query}"
    render 'override_conflict'
  end

  def ids_from_batch_conflict params
    assignments = params[:assignments]
    assignments.map { |a| a.shift.id }
  end

  def successful_batch_save assignments, assignment_attrs
    @errors = Assignment.batch_update(@assignments, assignment_attrs)
    @errors.empty?
  end



  # def send_batch_emails
  #   #input: old_assignments <Arr of Assignments> @assignments <Arr of Assignments> (implicit)
  #   #does: 
  #     # (1) constructs array of newly delegated shifts
  #     # (2) parses list of shifts into sublists for each rider
  #     # (3) parses list of shifts for restaurants
  #     # (4) [ SIDE EFFECT ] sends batch shift delegation email to each rider using params built through (1), (2), and (3)
  #   #output: Int (count of emails sent)
  #   delegations = delegations_from
  #   rider_shifts = RiderShifts.new(batch_delegations).array # (1), (2), (3)
  #   rider_shifts.each do |rs| # (4)
  #     RiderMailer.delegation_email( rs[:rider], rs[:shifts], rs[:restaurants], current_account ).deliver
  #   end
  #   rider_shifts.count
  # end



  # def batch_delegations
  #   #input: @assignments, @old_assignments (implicit)
  #   #does: builds array of assignments that the update action just delegated
  #   #output: Arr of new delegations
  #   delegations = []
  #   @assignments.each_with_index do |a, i| 
  #     delegations.push(a) if a.status == :delegated && ( @old_assignments[i].status != :delegated || @old_assignments[i].rider != a.rider )
  #   end
  #   delegations
  # end

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



    # def attempt_save_from action
    #   case action
    #   when :create
    #     message = lambda { |assignment| assignment.rider.nil? ? "Shift unassigned." : "Shift assigned to #{assignment.rider.contact.name}" }
    #     do_over = 'new'
    #   when :update
    #     message = lambda { |assignment| assignment.rider.nil? ? "Assignment updated (currently unassigned)." : "Assignment updated (Rider: #{assignment.rider.contact.name}, Status: #{@assignment.status.text})" }
    #     do_over = 'edit'
    #   end
    #   save_loop message, do_over
    # end  

    # def can_save? assignment
    #   conflicts = assignment.get_conflicts
      
    #   if assignment.no_conflicts? conflicts
    #     assignment.handle_no_conflicts conflicts
    #     other_shifts = get_other_shifts

    #     if no_double_bookings? other_shifts
    #       true
    #     end
    #   else
    #   end
    # end

    def save_loop message, do_over
      if no_conflicts?
        if no_double_bookings?
          if @assignment.save
            email_alert = send_email ? " Email sent to rider." : ""
            flash[:success] = message.call(@assignment) + email_alert
            redirect_to @base_path
          else
            render do_over
          end        
        else
          @override_subject = :double_booking
          render 'override_double_booking'
        end
      else 
        @override_subject = :conflict
        render 'override_conflict'
      end      
    end

    # def send_email 
    #   if @assignment.status == :delegated && ( @old_assignment.status != :delegated || @old_assignment.rider != @assignment.rider )
    #     RiderMailer.delegation_email(@assignment.rider, [ @assignment.shift ], [ @assignment.shift.restaurant ], current_account).deliver
    #     true
    #   else 
    #     false
    #   end 
    # end

    # def no_conflicts?
    #   return true if @assignment.rider.nil?
    #   @conflicts = @assignment.rider.conflicts_on @assignment.shift.start
    #   if @assignment.override_conflict
    #     @conflicts.each(&:destroy)
    #     @assignment.override_conflict = false # for future iterations of conflict-checking
    #     true
    #   else
    #     !@assignment.shift.conflicts_with? @conflicts
    #   end
    # end

    # def no_double_bookings?
    #   return true if @assignment.rider.nil?
    #   shifts = @assignment.rider.shifts_on @assignment.shift.start
    #   @other_shifts = shifts.reject { |shift| shift.id == @assignment.shift.id }
    #   if @assignment.override_double_booking
    #     @assignment.override_double_booking = false # for future iterations of double-booking-checking
    #     true
    #   else
    #     !@assignment.shift.double_books_with? @other_shifts
    #   end
    # end

    # BATCH CRUD HELPERS

    def load_shift_batch
      @shifts = Shift.where("id IN (:ids)", { ids: params[:ids] } ).order(:start)
    end

    def load_assignment_batch
      @assignments = @shifts.map(&:assignment)
    end


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

    def redirect_to_rider_shifts
      if @caller == :rider
        flash[:error] = "You can't create an assignment from a list of rider shifts. Try again from the shifts index or a list of restaurant shifts."
        redirect_to index_path
      end
    end

    def assignment_params
      params
        .require(:assignment)
        .permit(:rider_id, :shift_id, :status, :override_conflict, :override_double_booking)
    end



end
