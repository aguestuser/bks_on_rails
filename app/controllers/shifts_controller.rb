class ShiftsController < ApplicationController
  include ShiftPaths

  helper_method :sort_column, :sort_direction

  before_action :load_shift, only: [ :show, :edit, :update, :destroy ]
  before_action :load_caller # will call load_restaurant or load_rider if applicable, load_paths always
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :redirect_non_staffers, only: [ :index ]
  before_action :load_filters, only: [ :index ]
  before_action :load_shifts, only: [ :index ]

  def new
    @shift = Shift.new
    @shift.build_assignment

    load_form_args
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
        load_restaurants
        load_rider
      else 
        @caller = nil
        load_restaurants
      end
      load_shift_paths
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

    def load_filters
      if params[:filter]
        f = params[:filter]

        @filter = { # on filter or sort
          start: parse_time_filter_params( f[:start] ),
          :end => parse_time_filter_params( f[:end] ),
          restaurants: @caller == :restaurant ? [ @restaurant.id ] : f[:restaurants].map(&:to_i),
          riders: @caller == :rider ? [ @rider.id ] : f[:riders].map(&:to_i),
          status: f[:status]
        }
      else # on first load
        @filter = { 
          start: DateTime.now.beginning_of_week,
          :end => DateTime.now.end_of_week + 24.hours,
          restaurants: @caller == :restaurant ? [ @restaurant.id ] : Restaurant.all.map(&:id),
          riders: @caller == :rider ? [ @rider.id ] : Rider.all.map(&:id).push(0) ,
          status: AssignmentStatus.select_options.map(&:last)
        }
      end
    end

    def parse_time_filter_params p
      case p.class.name
      when 'String' # from sort click
        p.to_datetime
      when 'ActionController::Parameters' # from filter click
        DateTime.new( p[:year].to_i, p[:month].to_i, p[:day].to_i, 0 )
      end
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

    def filters
      [ filter_sql_str , filter_hash ]
    end

    def filter_sql_str
      str = "start > :filter_start 
        AND start < :filter_end 
        AND restaurants.id IN (:filter_restaurants)
        AND assignments.status IN (:filter_status)"
      str << rider_sql_str
    end

    def rider_sql_str
      if @filter[:riders].include? 0
        " AND (riders.id IN (:filter_riders) OR riders.id IS null)"
      else
        " AND riders.id IN (:filter_riders)"
      end      
    end

    def filter_hash #translates @filter hash built in load_filters
      { 
        filter_start: @filter[:start], 
        filter_end: @filter[:end], 
        filter_restaurants: @filter[:restaurants],
        filter_riders: @filter[:riders],
        filter_status: @filter[:status] 
      }      
    end

    def sort_column
      params[:sort] || "start" # default sort by date
    end

    def sort_direction
      params[:direction] || "asc"
    end

    def shift_params # permit :restaurant_id?
      params.require(:shift)
        .permit( :id, :restaurant_id, :start, :end, :urgency, :billing_rate, :notes,
          assignment_attributes: [ :id, :shift_id, :rider_id, :status ]
        )
    end
end
