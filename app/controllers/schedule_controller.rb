class ScheduleController < ApplicationController
  
  skip_authorize_resource

  include TimeboxableHelper, Filters

  # helper_method :period_header_to_id

  before_action :load_shift_filters, only: :shift_grid
  before_action :load_shifts, only: :shift_grid
  before_action :load_restaurants, only: :shift_grid

  def shift_grid
  end

  def availability_grid
  end

  private

    def load_shift_filters
      load_filters :for => :shifts, by: [ :time ]
    end

    def load_shifts
      @shifts = Shift
        .includes(associations)
        .where(*filters)
        .references(associations)
    end

    def associations
      { restaurant: :mini_contact, assignment: { rider: :contact } }
    end

    def load_restaurants
      @restaurants = @shifts.map(&:restaurant).uniq
    end

end
