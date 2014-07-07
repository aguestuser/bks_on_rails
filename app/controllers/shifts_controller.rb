class ShiftsController < ApplicationController
  
  before_action :get_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :get_shifts, only: [ :index ]
  before_action :get_restaurant, only: [ :new, :create ]
  # before_action :get_restaurant, only: [ :create, :edit, :update, :index ]

  def new
    @shift = Shift.new
    @restaurants = Restaurant.all
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      flash[:success] = "Shift created for #{@shift.restaurant.name}"
      redirect_to @shift
    else
      render 'new'
    end
  end

  def show
    @restaurant = @shift.restaurant
  end

  def edit
  end

  def index    
  end

  private

    def get_shift
      @shift = Shift.find(params[:id])
    end

    def get_shifts
      if params[:restaurant_id]
        @shifts = Shift.where(restaurant_id: params[:restaurant_id])
      else
        @shifts = Shift.all
      end
    end

    def get_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit(:restaurant_id, :start, :end, :period, :urgency, :billing_rate, :notes)    
    end
end
