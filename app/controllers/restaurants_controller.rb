class RestaurantsController < ApplicationController
  include LocatablesController, EquipablesController

  before_action :get_restaurant, only: [:show, :edit, :update, :destroy]
  before_action :check_credentials, only: [:new, :create]

  def new
      @restaurant = Restaurant.new
      @restaurant.build_mini_contact
      @restaurant.build_location # abstract to LocatablesController?
      @restaurant.build_work_specification
      @restaurant.build_rider_payment_info
      @restaurant.build_agency_payment_info
      @restaurant.build_equipment_set # abstract to EquipablesController?
      managers = @restaurant.managers.build
      managers.build_account.build_contact     
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      get_associations @restaurant
      flash[:success] = "Profile created for #{@contact.name}"
      redirect_to @restaurant
    else
      render 'new'
    end
  end

  def show
  end

  def index
    @restaurants = Restaurant.all
  end

  def edit
  end

  def update
    @restaurant.update(restaurant_params)
    if @restaurant.save
      flash[:success] = "#{@contact.name}'s profile has been updated"
      redirect_to restaurants_path
    else
      render 'edit'
    end
  end

  private
    def get_restaurant
      @restaurant = Restaurant.find(params[:id])
      get_associations @restaurant
      check_credentials
    end

    def get_associations(restaurant)
      @work_specification = restaurant.work_specification
      @contact = restaurant.mini_contact
      @managers = restaurant.managers
      @rider_payment = restaurant.rider_payment_info
      @agency_payment = restaurant.agency_payment_info
      @shifts = restaurant.shifts
    end

    # def get_restaurant_and_children
    #   @restaurant =Restaurant.includes(:managers).find(params[:id])
    # end

    def restaurant_params
      params.require(:restaurant)
        .permit( :active, :status, :brief,
          mini_contact_params, 
          managers_params,
          rider_payment_params,
          agency_payment_params,
          work_specification_params,
          equipment_params,
          location_params )
    end

    def mini_contact_params
      { mini_contact_attributes: [ :restaurant_id, :id, :name, :phone ] }
    end

    def managers_params
      { managers_attributes: [ :restaurant_id, :id, 
          account_attributes: [ :user_id, :id, :password, :password_confirmation,
              contact_attributes: [ :account_id, :id, :name, :title, :phone, :email ] ] ] }
    end

    def rider_payment_params
      { rider_payment_info_attributes: [ :restaurant_id, :id, :method, :rate, :shift_meal, :cash_out_tips ] }
    end

    def work_specification_params
      { work_specification_attributes: [  :restaurant_id, :id, :zone, :daytime_volume, 
                                          :evening_volume, :extra_work, :extra_work_description ] }
    end

    def agency_payment_params
      { agency_payment_info_attributes: [ :restaurant_id, :id, :method, :pickup_required ] }
    end

    def check_credentials
      case credentials
      when 'Manager'
        if !@restaurant.managers.include? current_account.user
          redirect_to root_path
        end        
      when 'Rider'
        redirect_to root_path
      when 'Staffer'
      else
        # nothing
      end
    end

end

