class ShiftsController < ApplicationController
  include ShiftPaths

  helper_method :sort_column, :sort_direction

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :load_shifts, only: [ :index ]

  def new
    @shift = Shift.new
    load_form_args
    @restaurants = Restaurant.all if !params.include? :restaurant_id
    @it = @shift
  end

  def create
    @shift = Shift.new(shift_params)
    load_form_args
    @it = @shift
    if @shift.save
      flash[:success] = "Shift created"
      redirect_to @shift_paths[:index]
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @shift.update(shift_params)
    if @shift.save
      flash[:success] = "Shift updated"
      redirect_to @shift_paths[:index]
    else
      render 'edit'
    end
  end

  def index
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @shift_paths[:index]
  end

  private

    def load_shift
      @shift = Shift.find(params[:id])
      @it = @shift
    end

   def load_caller
      if params.include? :restaurant_id
        @caller = :restaurant
        load_restaurant
      elsif params.include? :rider_id
        @caller = :rider
        load_rider
      else 
        @caller = nil
      end
      load_shift_paths
    end   

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    def load_form_args
      case @caller
      when :restaurant
        @form_args = [ @restaurant, @shift ]
      when :rider
        @form_args = [ @rider, @shift ]
      when nil
        @form_args = @shift
      end
    end

    def load_shifts
      case @caller
      when :restaurant
        @shifts = Shift.where(restaurant_id: @restaurant.id).page(params[:page]).order('start ASC')
      when :rider
        @shifts = Shift.joins(:assignment).where("assignments.rider_id = ?", @rider.id).page(params[:page]).order('start ASC')
      when nil
        if credentials == 'Staffer'
          # @shifts = Shift.all.page(params[:page]).order('start ASC')
          # @shifts = Shift.includes( restaurant: :mini_contact ).page(params[:page]).order('mini_contacts.name DESC') 
          @shifts = Shift
            .includes( restaurant: :mini_contact, assignment: { rider: :contact } )
            .page(params[:page])
            .order(sort_column + " " + sort_direction) 
        else 
          flash[:error] = "You don't have permission to view that page"
          redirect_to root_path
        end
      end
    end

    def sort_column
      #protect against SQL injection
      # .column_names.include?(params[:sort]) ? params[:sort] : "name"
      params[:sort] || "start" # default sort by date
      # 'mini_contacts.name DESC'
      # 'contacts.name ASC'
      # 'start ASC'
      # 'assignments.status'
    end

    def sort_direction
      params[:direction] || "asc"
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes )
    end
end
