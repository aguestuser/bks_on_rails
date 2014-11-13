class RestaurantsController < ApplicationController
  include LocatablesController, Paths
  before_action :load_restaurant, only: [:show, :edit, :update, :destroy]
  before_action :build_associations, only: [ :edit, :update ], if: :unedited?
  before_action :load_base_path

  def new
      @restaurant = Restaurant.new
      @restaurant.build_mini_contact
      @restaurant.build_location # abstract to LocatablesController?
      @restaurant.build_rider_payment_info
      
      managers = @restaurant.managers.build
      managers.build_account
      managers.build_contact
      
      @it = @restaurant     
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.managers << Manager.find( params[:manager_id] ) if params[:manager_id]
    @it = @restaurant
    
    if @restaurant.save
      flash[:success] = "Profile created for #{@restaurant.mini_contact.name}"
      redirect_to @restaurant
    else
      render 'new'
    end
  end

  def show
    start_t = now_unless_test.beginning_of_week
    end_t = start_t + 1.week
    @shifts = Shift
      .joins(:restaurant)
      .where(
        "start > (:start_t) AND start < (:end_t) AND restaurants.id = (:restaurant_id)",
        { start_t: start_t, end_t: end_t, restaurant_id: @restaurant.id }
      )
      .order('start asc')
    @shift_table = Table.new(:shift, @shifts, @caller, @base_path, nil, teaser: true )
  end

  def index
    if credentials == 'Staffer'
      @restaurants = Restaurant.all
      .page(params[:page])
      .joins(:mini_contact)
      .order('mini_contacts.name asc')
    else 
      flash[:error] = "You don't have permission to access that page."
      redirect_to root_path
    end 
  end

  def edit
  end

  def update
    @restaurant.attributes  = restaurant_params
    @restaurant.managers << Manager.find(params[:manager_ids]) if params[:manager_ids]
    if @restaurant.save
      @restaurant.unedited = false
      flash[:success] = "#{@restaurant.mini_contact.name}'s profile has been updated"
      redirect_to restaurant_path(@restaurant)
    else
      render 'edit'
    end
  end

  def export
    send_data Restaurant.export, filename: 'restaurants.csv'
  end

  private

    def load_restaurant
      @restaurant = Restaurant.find(params[:id])
      @caller = :restaurant
      @it = @restaurant
    end

    def unedited?
      @restaurant.unedited?
    end

    def build_associations
      @restaurant.build_work_specification
      @restaurant.build_agency_payment_info
      @restaurant.build_equipment_need
    end

    def load_restaurants
     
    end

    def restaurant_params
      params.require(:restaurant)
        .permit( :active, :status, :brief, :unedited, :manager_ids,
          mini_contact_params, 
          managers_params,
          rider_payment_params,
          agency_payment_params,
          work_specification_params,
          equipment_need_params,
          location_params )
    end

    def mini_contact_params
      # { mini_contact_attributes: [ :restaurant_id, :id, :name, :phone ] }
      { mini_contact_attributes: [ :restaurant_id, :name, :phone ] }
    end

    def managers_params
      { managers_attributes: [ :restaurant_id, :id, 
          account_attributes: [ :user_id, :id, :password, :password_confirmation ],
          contact_attributes: [ :contactable_id, :id, :name, :title, :phone, :email ] ] }
    end

    def rider_payment_params
      { rider_payment_info_attributes: [ :restaurant_id, :id, :method, :rate, :shift_meal, :cash_out_tips ] }
    end

    def work_specification_params
      { work_specification_attributes: [  :restaurant_id, :id, :zone, :daytime_volume, 
                                          :evening_volume, :extra_work, :extra_work_description ] }
    end

    def equipment_need_params
      { equipment_need_attributes: [ :restaurant_id, :bike_provided, :rack_required ] }
    end

    def agency_payment_params
      { agency_payment_info_attributes: [ :restaurant_id, :id, :method, :pickup_required ] }
    end
end

