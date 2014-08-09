class ScheduleController < ApplicationController
  
  skip_authorize_resource

  include TimeboxableHelper

  # helper_method :period_header_to_id

  before_action :load_filters
  before_action :load_shifts, only: :shift_grid
  before_action :load_restaurants, only: :shift_grid

  def shift_grid
  end

  def availability_grid
  end

  private

    def load_filters
      if params[:filter]
        f = params[:filter]

        @filter = { # on filter or sort
          start: parse_time_filter_params( f[:start] ),
          :end => parse_time_filter_params( f[:end] ),
        }
      else # on first load
        @filter = { 
          start: DateTime.now.beginning_of_week,
          :end => DateTime.now.end_of_week + 24.hours,
        }
      end
    end

    def load_shifts
      start_day = @filter[:start]
      end_day = @filter[:end]

      @shifts = Shift
        .includes(associations)
        .where(*filters)
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
        AND start < :filter_end"
    end

    def filter_hash #translates @filter hash built in load_filters
      { 
        filter_start: @filter[:start], 
        filter_end: @filter[:end]
      }      
    end

    def load_restaurants
      @restaurants = @shifts.map(&:restaurant).uniq
    end

end
