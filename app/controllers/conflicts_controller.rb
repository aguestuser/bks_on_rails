class ConflictsController < ApplicationController
  
  before_action :load_conflict, only: [ :edit, :update, :show, :destroy ]
  before_action :load_caller # callbacks: load_rider (if applicable), load_paths
  before_action :load_form_args, only: [ :new, :create, :edit, :update ]
  before_action :load_conflicts, only: [ :index ]
  # before_action :load_rider, only: [ :index, :destroy ]

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
  end

  def index
  end

  def destroy
    @conflict.destroy
    flash[:success] = "Conflict deleted"
    render 'index'
  end

  private

    def load_conflict
      @conflict = Conflict.find(params[:id])
    end

    def load_caller
      if params.include? :rider_id
        @caller = :rider
        load_rider
      else
        @caller = nil
      end
      load_paths
      load_conflicts
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end

    def load_paths
      case @caller
      when :rider
        @paths = {
          index: rider_conflicts_path(@rider),
          show: lambda { |conflict| rider_conflict_path(@rider, conflict) },
          edit: lambda { |conflict| edit_rider_conflict_path(@rider, conflict) },
          :new => new_rider_conflict_path(@rider)
        }
      when nil
        @paths = {
          index: conflicts_path,
          show: lambda { |conflict| conflict_path(conflict) },
          edit: lambda { |conflict| edit_conflict_path(conflict) },
          :new => new_conflict_path
        }
      end
    end

    def load_form_args
      case @caller
      when :rider
        @form_args = [ @rider, @conflict ]
      when nil
        @form_args = @conflict
      end
    end

    def load_conflicts
      case @caller
      when :rider
        @conflicts = Conflict.where("conflicts.rider_id = ?", params[:rider_id])        
      when nil
        @conflicts = Conflict.all
      end
    end
end
