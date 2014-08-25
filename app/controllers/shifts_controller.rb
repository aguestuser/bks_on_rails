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

  #CRUD ACTIONS

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
    @shift_table = Table.new(:shift, @shifts, @caller, @base_path, form: true)
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @base_path
  end

  # BATCH CRUD ACTIONS

  def batch_new
  end

  def batch_create
  end

  def batch_edit
    if params[:ids]
      load_shift_batch
      route_batch_edit params[:commit]
    else
      flash[:error] = "Oops! Looks like you didn't select any shifts to batch edit."
      render 'index'
    end
  end

  def route_batch_edit commit
    case commit
    when 'Batch Edit'
      batch_edit_shifts 
    when 'Batch Assign'
      load_assignment_batch
      batch_edit_assignments
    end
  end

  def batch_edit_shifts
    @errors = []
    render 'batch_edit_shifts'
  end

  def batch_update_shifts
    parse_shift_batch
    @errors = Shift.batch_update(@shifts, params[:shifts])
    
    if @errors.empty?
      flash[:success] = "Shifts successfully batch updated"
      redirect_to @base_path
    else
      render 'batch_edit_shifts'
    end
  end

  def batch_edit_assignments
    @errors = []
    render 'batch_edit_assignments'
  end

  def batch_update_assignments
    parse_assignment_batch
    @errors = Assignment.batch_update(@assignments, params[:assignments])

    if @errors.empty?
      flash[:success] = "Shifts successfully batch assigned"
      redirect_to @base_path
    else
      render 'batch_edit_assignments'
    end
  end

  private

    def load_shift_batch
      @shifts = Shift.where("id IN (:ids)", { ids: params[:ids] } ).order(:start)
    end

    def parse_shift_batch
      @shifts = Shift.where("id IN (:ids)", { ids: params[:shifts].map{ |s| s[:id] } } ).order(:start)
    end

    def load_assignment_batch
      @assignments = @shifts.map(&:assignment)
    end
    def parse_assignment_batch
      @assignments = Assignment.where("id IN (:ids)", { ids: params[:assignments].map{ |a| a[:id] } } )
      # raise @assignments.inspect
    end    



    def load_shift
      @shift = Shift.find(params[:id])
      @it = @shift
    end

    def load_caller
      if params.include? :restaurant_id
        @caller = :restaurant
        load_restaurant
        @caller_obj = @restaurant
      elsif params.include? :rider_id
        @caller = :rider
        load_restaurants
        load_rider
        @caller_obj = @rider
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

    def batch_shift_params
      params.require(:shifts)
        .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes,
          :base_path,
          assignment_attributes: [ :id, :shift_id, :rider_id, :status ]
        )
    end
end
