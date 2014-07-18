class RidersController < ApplicationController
  include UsersController, LocatablesController, EquipablesController

  # before_action :get_rider, only: [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  def new
    @rider = Rider.new
    @rider.build_account.build_contact # abstract to UsersController?
    @rider.build_location # abstract to LocatablesController?
    @rider.build_equipment_set # abstract to EquipablesController?
    @rider.build_rider_rating
    @rider.build_qualification_set
    @rider.build_skill_set
  end

  def create
    @rider = Rider.new(rider_params)
    if @rider.save
      refresh_account @rider
      flash[:success] = "Profile created for #{@contact.name}"
      redirect_to riders_path
    else
      render 'new'
    end
  end

  def show
  end

  def index
    @riders = Rider.all
  end

  def edit
  end

  def update
    @rider.update(rider_params)
    if @rider.save
      flash[:success] = "#{@contact.name}'s profile has been updated"
      redirect_to riders_path
    else
      render 'edit'
    end
  end

  private

    def get_rider
      @rider = Rider.find(params[:id])
      get_associations @rider
    end

    def get_associations(rider)
      @qualifications = rider.qualification_set
      @skills = rider.skill_set
      @rating = rider.rider_rating
      # @account, @contact, @location, @equipment made accessible by included modules 
    end

    def rider_params
      params.require(:rider)
        .permit(
          :active, 
          account_params, #included
          equipment_params, #included
          location_params, #included
          qualification_params,
          skill_params,
          rating_params
        )
    end

    def qualification_params
      { qualification_set_attributes: [ :rider_id, :id, :hiring_assessment, :experience, :geography ] }
    end

    def skill_params
      { skill_set_attributes: [ :rider_id, :id, :bike_repair, :fix_flats, :early_morning, :pizza ] }
    end

    def rating_params
      { rider_rating_attributes: [ :rider_id, :id, :reliability, :likeability, :speed, :initial_points ] }
    end
end
