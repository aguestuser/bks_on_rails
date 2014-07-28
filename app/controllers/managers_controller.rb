class ManagersController < ApplicationController
  include UsersController, ContactablesController
  before_action :load_manager, only: [ :show, :edit, :update, :destroy ]
  before_action :load_restaurant, only: [ :new, :create, :edit, :update ]

  def new
    @manager = Manager.new
    @manager.build_account # abstract to UsersController?
    @manager.build_contact # abstract to ContactablesController?
    @manager.restaurant = @restaurant
    @it = @manager
  end

  def create
    @manager = Manager.new(manager_params)
    @manager.restaurant_id = @restaurant.id
    @it = @manager
    if @manager.save
      flash[:success] = "Profile created for #{@manager.contact.name}."
      redirect_to redirect_path
    else
      render 'new'
    end
  end
  
  def show
  end

  def edit
  end

  def update
    if @manager.update(manager_params)
      flash[:success] = "#{@manager.contact.name}'s profile has been updated"
      redirect_to redirect_path
    else
      render 'edit'
    end    
  end

  def destroy
    @manager.destroy
    flash[:success] = "All information associated with #{@manager.contact.name} has been deleted"
    redirect_to restaurant_path(@manager.restaurant)
  end

  private

    def load_manager
      @manager = Manager.find(params[:id])
      @it = @manager
    end

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def refresh_restaurant(manager)
      manager.restaurant
    end

    def redirect_path
      if current_account.user == @manager
        restaurant_manager_path(@manager.restaurant, @manager)
      else
        restaurant_path(@manager.restaurant)
      end
    end

    def manager_params
      params.require(:manager).permit(account_params, contact_params)
    end
end
