# require 'week.rb'

class ScheduleController < ApplicationController  
  skip_authorize_resource
  include TimeboxableHelper, Filters

  before_action :load_subject # callbacks: load_restaurants OR load_riders
  before_action :load_filter_wrapper
  before_action :load_week
  before_action :load_y_axis_resource
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
        @view = :grid
      when 'availability_grid'
        @subject = :availability
        @view = :grid
      end
    end

    def load_filter_wrapper #included from controllers/concerns/filters.rb
      load_filters view: @view, by: [ :time ]
    end

    def load_week
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
        
        shift_wk = Week.new( start__, end__, Shift ).records
        conflict_wk = Week.new( start__, end__, Conflict ).records
        @week = CompoundWeek.new( start__, end__, shift_wk, conflict_wk  )
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
        # @riders = @week.records.map(&:record).uniq
        riders = @week.records.map(&:record).uniq
      end    

    def load_rows
      rows = @week.record.inject([]){ |arr, record| { record: record } }
      rows.each do |row|
        row[:index] = row_index record
        row[:sort_key] = sort_key record
      end
    end

    def row_index record
      case @subject
      when :shifts
        :restaurant
      when :availability
        if record.class == Conflict
          :status
        end
      end
    end

end
