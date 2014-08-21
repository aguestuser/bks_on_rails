class RidersController < ApplicationController
  include UsersController, ContactablesController, LocatablesController, EquipablesController, ShiftPaths, Paths
  # ShiftPaths, ConflictPaths, 

  before_action :load_rider, only: [ :show, :edit, :update, :destroy ]
  before_action :load_root_path

  def new
    @rider = Rider.new
    @rider.build_account # abstract to UsersController?
    @rider.build_contact # abstract to ContactablesController?
    @rider.build_location # abstract to LocatablesController?
    @rider.build_equipment_set # abstract to EquipablesController?
    @rider.build_rider_rating
    @rider.build_qualification_set
    @rider.build_skill_set

    @it = @rider
  end

  def create
    @rider = Rider.new(rider_params)
    @it = @rider
    if @rider.save
      flash[:success] = "Profile created for #{@rider.contact.name}"
      redirect_to riders_path
    else
      render 'new'
    end
  end

  def show
    @shifts = @rider.shifts.order(:start).first(5)
    @conflicts = @rider.conflicts.order(:start).first(5)

  end

  def index
    if credentials == 'Rider'
      @riders = Rider.find(current_account.user.id)
    elsif credentials == 'Staffer'
      @riders = Rider
        .all
        .page(params[:page])
        .joins(:contact)
        .order('contacts.name asc')


    else
      redirect_to @manager
    end
  end

  def edit
  end

  def update
    @rider.update(rider_params)
    if @rider.save
      flash[:success] = "#{@rider.contact.name}'s profile has been updated"
      case current_account.user
      when @rider
        redirect_to root_path
      else
        redirect_to riders_path
      end
    else
      render 'edit'
    end
  end

  private

    def load_rider
      @rider = Rider.find(params[:id])
      @caller = :rider
      @it = @rider
      # get_associations @rider
    end

    def caller
      @rider
    end

    def rider_params
      params.require(:rider)
        .permit(
          :active, 
          account_params, #included
          contact_params, #indluded
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
