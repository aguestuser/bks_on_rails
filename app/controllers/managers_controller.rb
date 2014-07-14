class ManagersController < ApplicationController
  include UsersController
  before_action :get_manager, only: [ :show, :edit, :update, :destroy ]
  before_action :get_restaurant, only: [ :new, :create, :edit, :update ]

  def new
    @manager = Manager.new
    @manager.build_account.build_contact
  end

  def create
    @manager = Manager.new(manager_params)
    @manager.restaurant_id = @restaurant.id
    if @manager.save
      flash[:success] = "Profile created for #{@manager.account.contact.name}."
      redirect_to restaurant_path(@restaurant.id)
    else
      render 'new'
    end
  end
  
  def show
  end

  def edit
  end

  def update
    @manager.update(manager_params)
    if @manager.save
      refresh_account @manager
      flash[:success] = "#{@contact.name}'s profile has been updated"
      redirect_to @manager.restaurant
    else
      render 'edit'
    end    
  end

  def destroy
    @manager.destroy
    flash[:success] = "All information associated with #{@contact.name} has been deleted"
    redirect_to restaurant_path(@manager.restaurant)
  end

  private

    def get_manager
      @manager = Manager.find(params[:id])
    end

    def get_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def refresh_restaurant(manager)
      manager.restaurant
    end

    def manager_params
      params.require(:manager).permit(:restaurant_id, account_params)
    end
end
