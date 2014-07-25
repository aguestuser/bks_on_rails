class ConflictsController < ApplicationController
  include ConflictPaths

  before_action :load_conflict, only: [ :edit, :update, :show, :destroy ]
  before_action :load_caller # callbacks: load_rider (if applicable), load_paths
  before_action :load_form_args, only: [ :new, :create, :edit, :update ]
  before_action :load_conflicts, only: [ :index ]
  # before_action :load_rider, only: [ :index, :destroy ]

  def new
    @conflict = Conflict.new
    load_form_args
  end

  def create
    @conflict = Conflict.new(conflict_params)
    load_form_args
    if @conflict.save
      flash[:success] = "Created conflict for #{@conflict.rider.contact.name}"
      redirect_to @conflict_paths[:index]
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @conflict.update(conflict_params)
    if @conflict.save
      flash[:success] = "Edited conflict for #{@conflict.rider.contact.name}"
      redirect_to @conflict_paths[:index]
    else
      render 'edit'
    end
  end

  def show
  end

  def index
  end

  def destroy
    @conflict.destroy
    flash[:success] = "Conflict deleted"
    redirect_to @conflict_paths[:index]
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
      load_conflict_paths #included from controllers/concerns/conflict_paths.rb
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
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

    def conflict_params
      params.require(:conflict).permit(:date, :period, :rider_id)
    end
end
