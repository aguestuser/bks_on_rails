class StaffersController < ApplicationController
  include UsersController, ContactablesController
  before_action :load_staffer, only: [:show, :edit, :update, :destroy]

  def new
    @staffer = Staffer.new
    @staffer.build_account #abstract?
    @staffer.build_contact #abstract?
    @it = @staffer
  end

  def create
    @staffer = Staffer.new(staffer_params)
    @it = @staffer
    if @staffer.save
      flash[:success] = "Profile created for #{@staffer.contact.name}."
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
      flash[:success] = "#{@staffer.contact.name}'s profile has been updated."
      redirect_to @staffer
    else
      render 'edit'
    end    
  end

  def destroy
    @staffer.destroy
    flash[:success] = "All information associated with #{@staffer.contact.name} has been deleted"
    redirect_to staffers_path
  end

  private

    def load_staffer
      @staffer = Staffer.find(params[:id])
      @it = @staffer
    end

    def staffer_params
        params.require(:staffer).permit(account_params, contact_params)
    end
end