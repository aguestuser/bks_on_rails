class StaffersController < ApplicationController
  
  before_action :get_staffer, only: [:show, :edit, :update, :destroy]

  def new
    @staffer = Staffer.new
    @staffer.build_contact_info
  end

  def create
    @staffer = Staffer.new(staffer_params)
    if @staffer.save
      flash[:success] = "Profile created for #{@staffer.name}."
      redirect_to @staffer
    else
      render 'new'
    end
  end

  def index
    @staffers = Staffer.all
  end

  def show
    @contact = @staffer.contact_info
  end

  def edit
  end

  def update
    @staffer.update(staffer_params)
    if @staffer.save
      flash[:success] = "#{@staffer.name}'s profile has been updated"
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
    end

    def staffer_params
      params.require(:staffer).permit(contact_info_attributes: [:name, :title, :phone, :email])
    end

    # def staffer_params
    #   params.require(:staffer, { :contact_info_id => @contact_info.id })
    # end

    # def contact_info_params
    #   # params[:contact_info].require(:name, :phone, :email, :title).permit(:street_address, :borough, :neighborhood)
    #   params.require(:staffer, contact_info: [:name, :phone, :email, :title]).permit(contact_info: [:street_address, :borough, :neighborhood])
    # end
end