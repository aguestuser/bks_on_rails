class ShiftsController < ApplicationController
  include Filters, Sortable, Paths

  # helper_method :sort_column, :sort_direction

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
    load_clone_shifts
    render 'batch_new'
  end

  def batch_create
    parse_clone_shifts
    @errors = Shift.batch_create(params[:shifts])

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
      # load_shift_batch # loads @shifts
      # raise @shifts.inspect
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

    def load_clone_shifts
      # raise params[:shifts].inspect
      attrs = Shift.parse_batch_attrs( params[:shifts].first )
      @shifts = num_shifts.times.map { |n| Shift.new( attrs ).increment_by( n.days ) ) }
    end

    def parse_clone_shifts
      @shifts = num_shifts.times.map{ |i| Shift.new( Shift.parse_batch_attrs(params[:shifts][i]) ) }
    end 

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
