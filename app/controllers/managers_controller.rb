class ManagersController < ApplicationController
  before_action :get_manager, only: [:show, :edit, :update, :destroy]

  def new
    @manager = Manager.new
    @manager.build_contact_info
  end

  def create
    @manager = Manager.new(manager_params)
    if @manager.save
      flash[:success] = "Profile created for #{@manager.name}."
      redirect_to @manager
    else
      render 'new'
    end
  end
  
  def show
    @contact = @manager.contact_info
  end

  def edit
  end

  def update
    @manager.update(manager_params)
    if @manager.save
      flash[:success] = "#{@manager.name}'s profile has been updated"
      redirect_to @manager
    else
      render 'edit'
    end    
  end

  def destroy
    @manager.destroy
    flash[:success] = "All information associated with #{@manager} has been deleted"
    redirect_to staffers_url
  end

  private

    def get_manager
      @manager = Manager.find(params[:id])
    end

    def manager_params
      params.require(:manager).permit(contact_info_attributes: [:name, :title, :phone, :email])
    end
end
