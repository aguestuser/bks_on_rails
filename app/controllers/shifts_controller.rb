class ShiftsController < ApplicationController
  include Filters, Sortable, Paths

  # helper_method :sort_column, :sort_direction

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_base_path
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :redirect_non_staffers, only: [ :index ]
  before_action :load_filter_wrapper, only: [ :index, :batch_edit_assignment, :batch_update_assignment ]
  before_action :load_shifts, only: [ :index, :batch_edit_assignment, :batch_update_assignment ]

  def new
    @shift = Shift.new
    load_form_args
    @it = @shift
  end

  def create
    @shift = Shift.new(shift_params.except(:base_path))
    @shift.assignment = Assignment.new
    load_form_args
    @it = @shift
    if @shift.save
      flash[:success] = "Shift created"
      redirect_to @base_path
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @shift.update(shift_params.except(:base_path))
    if @shift.save
      flash[:success] = "Shift updated"
      redirect_to @base_path
    else
      render 'edit'
    end
  end

  def index
    @shift_table = Table.new(:shift, @shifts, @caller, @base_path)
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @base_path
  end

  def batch_new
  end

  def batch_create
  end

  def batch_edit
  end

  def batch_update
  end

  def batch_edit_assignment
    @shift_table = Table.new(:shift, @shifts, @caller, @base_path, form: true)
  end

  def batch_update_assignment
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
        load_restaurants
        load_rider
      else 
        @caller = nil
        load_restaurants
      end
    end   

    def load_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def load_restaurants
      @restaurants = Restaurant.all
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

    def redirect_non_staffers
      if @caller.nil?
        unless credentials == 'Staffer'
          flash[:error] = "You don't have permission to view that page"
          redirect_to root_path          
        end
      end
    end

    def load_filter_wrapper
      load_filters subject: :shifts, view: :table, by: [ :time, :restaurants, :riders, :status ]
    end

    def load_shifts
      @shifts = Shift
        .includes(associations)
        .where(*filters)
        .page(params[:page])
        .order(sort_column + " " + sort_direction)
        .references(associations)
    end

    def associations
      { restaurant: :mini_contact, assignment: { rider: :contact } }
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes,
          :base_path,
          assignment_attributes: [ :id, :shift_id, :rider_id, :status ]
        )
    end
end
