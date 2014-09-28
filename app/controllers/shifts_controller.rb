class ShiftsController < ApplicationController
  include Filters, Sortable, Paths

  helper_method :blank_shift_from

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_base_path
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :redirect_non_staffers, only: [ :index ]
  before_action :load_filter_wrapper, only: [ :index, :batch_edit ]
  before_action :load_shifts, only: [ :index ]
  before_action :load_empty_errors, only: [ :route_batch_edit, :clone_new, :batch_new ]

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
    load_table
  end

  def destroy
    @shift.destroy
    flash[:success] = "Shift deleted"
    redirect_to @base_path
  end

  def hanging
    
  end

  # BATCH CRUD ACTIONS

  def clone_new
  end

  def batch_new
    # load_clone_shifts # loads @shifts
    cloned_params = num_shifts.times.map{ params[:shifts].first }
    @shifts = Shift.batch_from_params(cloned_params).each_with_index.map{ |s, i| s.increment_by(i.days) }

    render 'batch_new'
  end

  def batch_create
    shifts = Shift.batch_from_params params[:shifts]
    @errors = Shift.batch_create shifts

    if @errors.empty?
      flash[:success] = "#{params[:shifts].count} shifts successfully created"
      redirect_to @base_path
    else
      render 'batch_new'
    end
  end

  def batch_edit
    if params[:ids]
      load_shift_batch # loads @shifts
      route_batch_edit params[:commit]
    else
      flash[:error] = "Oops! Looks like you didn't select any shifts to batch edit."
      load_shifts
      load_table
      render 'index'
    end
  end

  def route_batch_edit commit
    query = params.extract!(:ids, :base_path).to_query

    case commit
    when 'Batch Edit'
      @errors = []
      render 'batch_edit' 
    when 'Batch Assign' 
      redirect_to "/assignment/batch_edit?#{query}"
    when 'Uniform Assign'
      redirect_to "/assignment/batch_edit_uniform?#{query}"
    end
  end

  def batch_update
    old_shifts = old_shifts_from params # loads @shifts
    new_shifts = new_shifts_from params
    @errors = Shift.batch_update(old_shifts, new_shifts)

    if @errors.empty?
      flash[:success] = "Shifts successfully batch edited"
      redirect_to @base_path
    else
      render "batch_edit"
    end
  end

  def build_clone_week_preview
    @restaurants_with_shifts = Restaurant.with_shifts_this_week
    render 'build_clone_week_preview'
    # view has dropdown for restaurant & start_t submits GET to #preview_week
  end

  def preview_clone_week
    @restaurants = Restaurant.find(params[:restaurant_ids].map(&:to_i))

    @this_week_start = Time.zone.parse params[:week_start]
    @next_week_start = @this_week_start + 1.week
    this_week_end = @this_week_start + 1.week
    
    @restaurant_shifts = RestaurantShifts.new(@restaurants, @this_week_start).increment_week
  end

  def save_clone_week
    @restaurant_shifts = RestaurantShifts.from_params params
    @errors = @restaurant_shifts.save
    if @errors.empty?
      flash[:succes] = "Schedules cloned for #{@restaurant_shifts.arr.count} restaurants"
      redirect_to @base_path
    else
      render 'preview_clone_week'
    end
  end

  private  

    #CRUD HELPERS

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
      # raise @caller.inspect
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

    def load_shifts
      @shifts = Shift
        .includes(associations)
        .where(*filters)
        .page(params[:page])
        .order(sort_column + " " + sort_direction)
        .references(associations)
    end

    # BATCH CRUD HELPERS

    def load_empty_errors
      @errors = []
    end

    # def load_clone_shifts
    #   cloned_params = num_shifts.times.map{ params[:shifts].first }
    #   @shifts = Shift.batch_from_params cloned_params
    # end

    # def parse_clone_shifts
    #   @shifts = Shift.batch_from_params params[:shifts] 
    # end 

    def num_shifts
      params[:num_shifts] ? params[:num_shifts].to_i : params[:shifts].count
    end

    def load_shift_batch
      @shifts = Shift.where("id IN (:ids)", { ids: params[:ids] } ).order(:start)
    end

    def old_shifts_from params
      Shift.where("id IN (:ids)", { ids: params[:shifts].map{ |s| s[:id] } } ).order(:start)
    end

    def new_shifts_from params
      attr_arr = params[:shifts].map { |param_hash| Assignment.attributes_from param_hash }
      attr_arr.map{ |attrs| Shift.new(attrs) }
    end

    # VIEW INTERACTION HELPERS

    def load_table
      @shift_table = Table.new(:shift, @shifts, @caller, @base_path, form: true)
    end

    def load_filter_wrapper
      load_filters subject: :shifts, view: :table, by: [ :time, :restaurants, :riders, :status ]
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

    def blank_shift_from restaurant, week_start
      Shift.new(restaurant_id: restaurant.id, start: week_start + 12.hours, :end => week_start + 18.hours )
    end

    # HTTP HELPERS

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

    def redirect_non_staffers
      if @caller.nil?
        unless credentials == 'Staffer'
          flash[:error] = "You don't have permission to view that page"
          redirect_to root_path          
        end
      end
    end

    # def batch_shift_params
    #   params.require(:shifts)
    #     .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes,
    #       :base_path,
    #       assignment_attributes: [ :id, :shift_id, :rider_id, :status ]
    #     )
    # end
end
