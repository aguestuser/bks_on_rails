class ShiftsController < ApplicationController
  
  before_action :get_shift, [:show, :edit, :update, :destroy]

  def new
    @shift = Shift.new
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
  end

  def edit
  end

  def index
    @shifts = Shift.all
  end

  private

    def get_shift
      @shift = Shift.find(params[:id])
    end

    def restaurant_params # permit :restaurant_id?
      params.require(:shift)
        .permit(:start, :end, :period, :urgency, :billing_rate, :notes)    
    end
end
