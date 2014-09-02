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
    @old_assignment = Assignment.new(@assignment.attributes)
    @assignment.attributes = assignment_params
    attempt_save_from :update
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
    load_shift_batch # loads @shifts
    load_assignment_batch #loads @assignments
    render 
  end

  def batch_update
    parse_assignment_batch # loads @assignments
    @old_assignments = @assignments.map { |a| Assignment.new(a.attributes) }
    @errors = Assignment.batch_update(@assignments, params[:assignments])

    if @errors.empty?
      email_alert = send_batch_emails == 0 ? "" : " -- #{send_batch_emails} emails sent"
      flash[:success] = "Assignments successfully batch edited" << email_alert
      redirect_to @base_path
    else
      render "assignments/batch_edit"
    end
  end

  def send_batch_emails 
    #input: @assignments, @old_assignments (implicit)
    #does: 
      # (1) constructs array of newly delegated shifts
      # (2) parses list of shifts into sublists for each rider
      # (3) parses list of shifts for restaurants
      # (4) [ SIDE EFFECT ] sends batch shift delegation email to each rider using params built through (1), (2), and (3)
    #output: Int (count of emails sent)

    rider_shifts = RiderShifts.new(batch_delegations).array # (1), (2), (3)
    rider_shifts.each do |rs| # (4)
      RiderMailer.delegation_email( rs[:rider], rs[:shifts], rs[:restaurants], current_account )
    end
    rider_shifts.count
  end



  def batch_delegations
    #input: @assignments, @old_assignments (implicit)
    #does: builds array of assignments that the update action just delegated
    #output: Arr of new delegations
    delegations = []
    @assignments.each_with_index do |a, i| 
      delegations.push(a) if a.status == :delegated && @old_assignments[i] != :delegated
    end
    delegations
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

    def attempt_save_from action
      case action
      when :create
        message = lambda { |assignment| assignment.rider.nil? ? "Shift unassigned." : "Shift assigned to #{assignment.rider.contact.name}" }
        do_over = 'new'
      when :update
        message = lambda { |assignment| assignment.rider.nil? ? "Assignment updated (currently unassigned)." : "Assignment updated (Rider: #{assignment.rider.contact.name}, Status: #{@assignment.status.text})" }
        do_over = 'edit'
      end
      save_loop message, do_over
    end  

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

    def send_email 
      if @assignment.status == :delegated && ( @old_assignment.status != :delegated || @old_assignment.rider != @assignment.rider )
        RiderMailer.delegation_email(@assignment.rider, [ @assignment.shift ], [@assignment.restaurant] current_account, Time.zone.now).deliver
        true
      else 
        false
      end 
    end

    def no_conflicts?
      return true if @assignment.rider.nil?
      @conflicts = @assignment.rider.conflicts_on @assignment.shift.start
      if @assignment.override_conflict
        @conflicts.each(&:destroy)
        @assignment.override_conflict = false # for future iterations of conflict-checking
        true
      else
        !@assignment.shift.conflicts_with? @conflicts
      end
    end

    def no_double_bookings?
      return true if @assignment.rider.nil?
      shifts = @assignment.rider.shifts_on @assignment.shift.start
      @other_shifts = shifts.reject { |shift| shift.id == @assignment.shift.id }
      if @assignment.override_double_booking
        @assignment.override_double_booking = false # for future iterations of double-booking-checking
        true
      else
        !@assignment.shift.double_books_with? @other_shifts
      end
    end

    # BATCH CRUD HELPERS

    def load_shift_batch
      @shifts = Shift.where("id IN (:ids)", { ids: params[:ids] } ).order(:start)
    end

    def load_assignment_batch
      @assignments = @shifts.map(&:assignment)
    end

    def parse_assignment_batch
      @assignments = Assignment.where("id IN (:ids)", { ids: params[:assignments].map{ |a| a[:id] } } )
      # raise @assignments.inspect
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
