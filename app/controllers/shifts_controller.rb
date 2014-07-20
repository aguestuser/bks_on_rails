class ShiftsController < ApplicationController
  
  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_restaurant, if: :restaurant_present?
  before_action :load_rider, if: :rider_present?
  before_action :load_shifts, only: [ :index ]

  def new
    @shift = Shift.new
    @restaurants = Restaurant.all
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      flash[:success] = "Shift created"
      load_shifts
      render 'index'
    else
      render 'new'
    end
  end

  def show
    @restaurant = @shift.restaurant
  end

  def edit
  end

  def update
    @shift.update(shift_params)
    if @shift.save
      flash[:success] = "Shift updated"
      load_shifts
      render 'index'
    else
      render 'edit'
    end
  end

  def index
    if params.include? :restaurant_id
      @restaurant = Restaurant.find(params[:restaurant_id])
      @shifts = Shift.where(restaurant_id: params[:restaurant_id])
    end
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to restaurant_path(@shift.restaurant)
  end

  private

    def load_shift
      @shift = Shift.find(params[:id])
    end

    def restaurant_present?
      !params[:restaurant_id].nil?
    end

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def rider_present?
      !params[:rider_id].nil?
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    def load_shifts
      if @restaurant
        @shifts = Shift.where(restaurant_id: params[:restaurant_id])
      elsif @rider
        @shifts = Shift.joins(:assignment).where("assignments.rider_id = ?", @rider.id)
      else
        @shifts = Shift.all
      end
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit(:restaurant_id, :start, :end, :urgency, :billing_rate, :notes )
    end
end
