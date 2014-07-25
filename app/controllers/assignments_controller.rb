class AssignmentsController < ApplicationController
  include ShiftPaths

  # NOTE: always call through shift_assignment_path, NEVER call directly through assignment_path

  before_action :load_shift
  before_action :load_assignment, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :redirect_to_rider_shifts, only: [ :new, :create ]

  def new
    @assignment = Assignment.new
    load_form_args
    # @assignment.shift = @shift      
  end

  def create
    @assignment = Assignment.new(assignment_params)
    load_form_args

    if @assignment.save
      flash[:success] = "Shift assigned to #{@assignment.rider.contact.name}"
      redirect_to @shift_paths[:index]
    else
      render 'new'
    end
    
  end

  def edit
  end

  def update
    @assignment.update(assignment_params)
    if @assignment.save
      flash[:success] = "Assignment updated (Rider: #{@assignment.rider.name}, Status: #{@assignment.status.text})"
      redirect_to @shift_paths[:index]
    else
      render 'edit'
    end
  end

  def show
  end

  def index
  end

  def destroy
    @assignment.destroy
    flash[:success] = 'Assignment deleted'
    redirect_to @shift_paths[:index]
  end

  private 

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
      load_shift_paths # included from concerns/shift_paths.rb
    end

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end  

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

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
        redirect_to @shift_paths[:index]
      end
    end  

    def assignment_params
      params
        .require(:assignment)
        .permit(:rider_id, :shift_id, :status)
    end


end
