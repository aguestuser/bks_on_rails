class StaffersController < ApplicationController
  include UsersController

  before_action :get_staffer, only: [:show, :edit, :update, :destroy]

  def new
    # new_user.build_contact_info

    # def new_user
    #   @user = User.new
    # end

    @staffer = Staffer.new
    @staffer.build_user_info.build_contact_info
  end

  def create
    @staffer = Staffer.new(staffer_params)
    if @staffer.save
      flash[:success] = "Profile created."
      redirect_to @staffer
    else
      render 'new'
    end
  end

  def show
    @contact_info = @staffer.contact_info
  end

  def index
    @staffers = Staffer.all
  end

  def edit
  end

  def update
    @staffer.update(staffer_params)
    if @staffer.save
      flash[:success] = "#{@contact.name}'s profile has been updated"
      redirect_to @staffer
    else
      render 'edit'
    end    
  end

  def destroy
    @staffer.destroy
    flash[:success] = "All information associated with #{@staffer} has been deleted"
    redirect_to staffers_url
  end

  private

    def get_staffer
      @staffer = Staffer.find(params[:id])
      @user = @staffer.user_info
      @contact = @user.contact_info
    end

    def staffer_params
      params.require(:staffer).permit(user_info_params)
    end

    # def user_info_params
    #   { 
    #     user_info_attributes: [
    #       :id, :user_id, :user_type,
    #       contact_info_attributes: [
    #         :id, :contact_id, :name, :title, :email, :phone
    #       ]
    #     ] 
    #   }
    # end

end