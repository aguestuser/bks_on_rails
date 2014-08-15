# require 'week.rb'

class GridController < ApplicationController  
  skip_authorize_resource
  include TimeboxableHelper, Filters, Sortable

  before_action :load_subject # callbacks: load_restaurants OR load_riders
  before_action :load_filter_wrapper
  before_action :load_week
  before_action :load_y_axis_resource
  before_action :load_sort_params
  # before_action :load_restaurants, only: :shift_grid

  def shifts
    @grid = Grid.new(@week, :restaurant, @restaurants, @sort_key, @sort_dir)
    @root_path = '/grid/shifts'
  end

  def availability
    @grid = Grid.new(@week, :rider, @riders, @sort_key, @sort_dir)
    @root_path = '/grid/availability'
  end

  private

    def load_subject
      @view = :grid
      @subject = params[:action].to_sym
    end

    def load_filter_wrapper #included from controllers/concerns/filters.rb
      load_filters view: @view, by: [ :time ]
    end

    def load_week
      load_shift_week
      case @subject
      when :shifts
        load_shift_week
      when 
        load_availability_week
      end
    end

      def load_shift_week
        @week = Week.new( @filter[:start], @filter[:end], Shift )
      end

      def load_availability_week
        start__ = @filter[:start]
        end__ = @filter[:end]
        
        shift_wk = Week.new( start__, end__, Shift )
        conflict_wk = Week.new( start__, end__, Conflict )
        @week = CompoundWeek.new( start__, end__, [ shift_wk, conflict_wk ] )
      end

    def load_y_axis_resource
      case @subject
      when :shifts
        load_restaurants
      when :availability
        load_riders
      end
    end

      def load_restaurants
        @restaurants = @week.records.map(&:restaurant).uniq
      end

      def load_riders
        @riders = Rider.all.to_a.uniq
      end

    def load_sort_params
      @sort_key = params[:sort].to_i || 0
      @sort_dir = params[:direction] || 'asc'      
    end    


end
