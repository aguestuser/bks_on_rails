class ShiftsController < ApplicationController
  include ShiftPaths
  
  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :load_shifts, only: [ :index ]

  def new
    @shift = Shift.new
    load_form_args
    @restaurants = Restaurant.all if !params.include? :restaurant_id
    @it = @shift
  end

  def create
    @shift = Shift.new(shift_params)
    load_form_args
    @it = @shift
    if @shift.save
      flash[:success] = "Shift created"
      redirect_to @paths[:index]
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @shift.update(shift_params)
    if @shift.save
      flash[:success] = "Shift updated"
      redirect_to @paths[:index]
    else
      render 'edit'
    end
  end

  def index
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @paths[:index]
  end

  private

    def load_shift
      @shift = Shift.find(params[:id])
      @it = @shift
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
      load_paths
    end   

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    # def load_paths
    #   case @caller
    #   when :restaurant
    #     @paths = {
    #       show_shift: lambda { |shift| restaurant_shift_path(@restaurant, shift) },
    #       edit_shift: lambda { |shift| edit_restaurant_shift_path(@restaurant, shift) },
    #       new_shift: new_restaurant_shift_path,
    #       index: restaurant_shifts_path(@restaurant),
    #       show_assignment: lambda { |shift, assignment| restaurant_shift_assignment_path(@restaurant, shift, assignment) },
    #       edit_assignment: lambda { |shift, assignment| edit_restaurant_shift_assignment_path(@restaurant, shift, assignment) },
    #       new_assignment: lambda { |shift| new_restaurant_shift_assignment_path(@restaurant, shift) }
    #     }
    #   when :rider
    #     @paths = {
    #       show_shift: lambda { |shift| rider_shift_path(@rider, shift) },
    #       edit_shift: lambda { |shift| edit_rider_shift_path(@rider, shift) },
    #       new_shift: new_rider_shift_path,
    #       index: rider_shifts_path(@rider),
    #       show_assignment: lambda { |shift, assignment| rider_shift_assignment_path(@rider, shift, assignment) },
    #       edit_assignment: lambda { |shift, assignment| edit_rider_shift_assignment_path(@rider, shift, assignment) },
    #       new_assignment: lambda { |shift| new_rider_shift_assignment_path(@rider, shift) }
    #     }
    #   when nil
    #     @paths = {
    #       show_shift: lambda { |shift| shift_path(shift) },
    #       edit_shift: lambda { |shift| edit_shift_path(shift) },
    #       new_shift: new_shift_path,
    #       index: shifts_path,
    #       show_assignment: lambda { |shift, assignment| shift_assignment_path(shift, assignment) },
    #       edit_assignment: lambda { |shift, assignment| edit_shift_assignment_path(shift, assignment) },
    #       new_assignment: lambda { |shift| new_shift_assignment_path(shift) }          
    #     }
    #   end
    # end

    def load_form_args
      case @caller
      when :restaurant
        @form_args = [ @restaurant, @shift ]
      when :rider
        @form_args = [ @rider, @shift ]
      when nil
        @form_args = @shift
      end
    end

    def load_shifts
      case @caller
      when :restaurant
        @shifts = Shift.where(restaurant_id: @restaurant.id)
      when :rider
        @shifts = Shift.joins(:assignment).where("assignments.rider_id = ?", @rider.id)
      when nil
        if credentials == 'Staffer'
          @shifts = Shift.all
        else 
          flash[:error] = "You don't have permssion to view that page"
          redirect_to root_path
        end
      end
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes )
    end
end
