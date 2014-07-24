class ShiftsController < ApplicationController
  
  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable
  before_action :load_index_path 
  before_action :load_shifts, only: [ :create, :update, :index ]

  def new
    @shift = Shift.new
    @restaurants = Restaurant.all
    @it = @shift
  end

  def create
    @shift = Shift.new(shift_params)
    @it = @shift
    if @shift.save
      flash[:success] = "Shift created"
      load_shifts
      redirect_to @index_path
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
      load_shifts
      redirect_to @index_path
    else
      render 'edit'
    end
  end

  def index
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @index_path
  end

  public

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
    end   

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    def load_index_path
      case @caller
      when :restaurant
        @index_path = restaurant_shifts_path(@restaurant)  
      # when :rider
      #   @index_path = rider_shifts_path(@rider) 
      when nil
        @index_path = shifts_path
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
