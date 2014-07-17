class StaffersController < ApplicationController
  include UsersController

  before_action :get_staffer, only: [:show, :edit, :update, :destroy]

  def new
    @staffer = Staffer.new
    @staffer.build_account.build_contact
  end

  def create
    @staffer = Staffer.new(staffer_params)
    if @staffer.save
      refresh_account @staffer
      flash[:success] = "Profile created for #{@contact.name}."
      redirect_to @staffer
    else
      render 'new'
    end
  end

  def show
  end

  def index
    @staffers = Staffer.all
  end

  def edit
  end

  def update
    @staffer.update(staffer_params)
    if @staffer.save
      refresh_account @staffer
      flash[:success] = "#{@contact.name}'s profile has been updated."
      redirect_to @staffer
    else
      render 'edit'
    end    
  end

  def destroy
    @staffer.destroy
    flash[:success] = "All information associated with #{@contact.name} has been deleted"
    redirect_to staffers_path
  end

  private

    def get_staffer
      @staffer = Staffer.find(params[:id])
    end

    def staffer_params
        params.require(:staffer).permit(account_params)
    end
end