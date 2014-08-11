# require 'week.rb'

class ScheduleController < ApplicationController  
  skip_authorize_resource
  include TimeboxableHelper, Filters

  # before_action :load_shift_filters, only: :shift_grid
  # before_action :load_shifts, only: :shift_grid
  before_action :load_subject # callbacks: load_restaurants OR load_riders
  before_action :load_filter_wrapper
  before_action :load_week
  before_action :load_restaurants, only: :shift_grid
  # before_action :load_restaurants, only: :shift_grid

  def shift_grid
  end

  def availability_grid
  end

  private

    def load_subject
      case params[:action]
      when 'shift_grid'
        @subject = :shifts
        @view = :shift_grid
        @klass = Shift
      when 'availability_grid'
        @subjects = [ :conflicts, :assignments ]
        @klasses = [ Conflict, Assignment ]
      end
    end

    def load_filter_wrapper #included from controllers/concerns/filters.rb
      load_filters view: @view, by: [ :time ]
    end

    def load_week
      @week = Week.new( @filter[:start], @filter[:end], @klass )
    end

    def load_restaurants
      @restaurants = @week.records.map(&:restaurant).uniq
    end

    # def load_shifts
    #   @shifts = Shift
    #     .includes(associations)
    #     .where(*filters)
    #     .references(associations)
    # end

    # def associations
    #   { restaurant: :mini_contact, assignment: { rider: :contact } }
    # end

        # def load_restaurants
    #   @restaurants = @shifts.map(&:restaurant).uniq
    # end



end
