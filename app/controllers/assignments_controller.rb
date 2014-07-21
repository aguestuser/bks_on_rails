class AssignmentsController < ApplicationController
  
  # NOTE: always call through shift path

  before_action :load_shift, only: [ :new, :create ]
  before_action :load_assignment, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable
  before_action :load_index_path
  before_action :redirect_to_rider_shifts, only: [ :new, :create ]

  def new
    @assignment = Assignment.new
    @assignment.shift = @shift      
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      flash[:success] = "Shift assigned to #{@assignment.rider.account.contact.name}"
      redirect_to @index_path
    else
      render 'new'
    end
    
  end

  def edit
  end

  def update
    @assignment.update(assignment_params)
    if @assignment.save
      flash[:success] = "Assignment updated"
      redirect_to @index_path
    else
      render 'edit'
    end
  end

  def show
  end

  def index
  end

  def destroy
    
  end

  private 

    def load_shift
      @shift = Shift.find(params[:shift_id])
    end

    def load_assignment
      if params.include? :assignment_id
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

    def redirect_to_rider_shifts
      if @caller == :rider
        flash[:error] = "You can't create an assignment from a list of rider shifts. Try again from the shifts index or a list of restaurant shifts."
        redirect_to @index_path
      end
    end

    def load_index_path
      case @caller
      when :restaurant
        @index_path = restaurant_shifts_path(@restaurant)
      when :rider
        @index_path = rider_shifts_path(@rider)
      when nil
        @index_path = shifts_path
      end
    end    

    # def load_assignments
    #   if shift_present?
    #     @assignments = Assignment.where(shift: params[:shift_id])
    #   elsif rider_present?
    #     @assignments = Assignment.where(rider_id: params[:rider_id])
    #   else
    #     @assignments = Assignment.all
    #   end 
    # end

    def assignment_params
      params
        .require(:assignment)
        .permit(:rider_id, :shift_id, :status)
    end


end
