class RestaurantsController < ApplicationController
  # include ContactInfoEnums # /app/helpers/contact_info_enums.rb
  # include RestaurantEnums # /app/helpers/restaurant_enums.rb

  before_action :get_restaurant, only: [:show, :edit, :update, :destroy]
  before_action :get_enums, only: [:new, :create, :edit]

  def new
      @restaurant ||= Restaurant.new
      @restaurant.build_contact_info
      @restaurant.build_work_arrangement
      managers ||= @restaurant.managers.build
      managers.build_contact_info      
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
          contact_info_attributes:
            [ :name, :phone, :street_address, :borough, :neighborhood ],
          managers_attributes: 
            [ contact_info_attributes: 
              [ :name, :title, :phone, :email ] ],
          work_arrangement_attributes:
            [ :zone, :daytime_volume, :evening_volume, 
              :pay_rate, :shift_meal, :cash_out_tips, :rider_on_premises,
              :extra_work, :extra_work_description,
              :bike, :lock, :rack, :bag, :heated_bag ] )
    end 

    def get_enums
      # @boroughs = Boroughs
      # @neighborhoods = Neighborhoods
      # @statuses = Statuses
      # @rider_payment_methods = RiderPaymentMethods
      # @agency_payment_methods = AgencyPaymentMethods
    end

end

