class RestaurantsController < ApplicationController
  include ContactInfoEnums
  before_action :get_restaurant, only: [:show, :edit, :update, :destroy]

  def new
    @restaurant = Restaurant.new
    @restaurant.build_contact_info
    @restaurant.build_work_arrangement
    @restaurant.managers.build
    @boroughs = Boroughs.values
    @neighborhoods = Neighborhoods.values
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      flash[:success] = "Profile created for #{@restaurant}"
      redirect_to @restaurant
    else
      render 'new'
    end
  end

  def show
    @contact_info = @restaurant.contact_info
    @work_arrangement = @restaurant.work_arrangement
    @managers = @restaurant.managers
  end

  def index
    @restaurant = Restaurant.all
  end

  def edit
  end

  def update
    @restaurant_params.update(restaurant_params)
    if @restaurant.save
      flash[:success] = "#{@restaurant}'s profile has been updated"
      redirect_to @restaurant
    else
      render 'edit'
    end
  end

  private
    def get_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def restaurant_params
      params.require(:restaurant)
        .permit(
          manager_attributes: 
            [ contact_info_attributes: 
              [ :name, :title, :phone, :email ] ],
          work_arrangement_attributes:
            [ :zone, :daytime_volume, :evening_volume, 
              :pay_rate, :shift_meal, :cash_out_tips, :rider_on_premises,
              :extra_work, :extra_work_description,
              :bike, :lock, :rack, :bag, :heated_bag ] )
    end  
end
