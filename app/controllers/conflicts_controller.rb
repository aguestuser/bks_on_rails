class ConflictsController < ApplicationController
  include Paths

  before_action :load_conflict, only: [ :edit, :update, :show, :destroy ]
  before_action :load_caller # callbacks: load_rider (if applicable)
  before_action :load_root_path
  before_action :load_form_args, only: [ :edit, :update ]
  before_action :load_conflicts, only: [ :index ]
  # before_action :load_rider, only: [ :index, :destroy ]

  def new
    @conflict = Conflict.new(start: params[:start], :end => params[:end])
    load_form_args
  end

  def create
    @conflict = Conflict.new(conflict_params.except(:root_path))
    load_form_args
    if @conflict.save
      flash[:success] = "Created conflict for #{@conflict.rider.contact.name}"
      redirect_to @root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @conflict.update(conflict_params.except(:root_path))
    if @conflict.save
      flash[:success] = "Edited conflict for #{@conflict.rider.contact.name}"
      # path = !@root_path.nil? ? @root_path : @conflict_paths[:index]
      redirect_to @root_path
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
    path = @root_path ? @root_path : @conflict_paths[:index]
    redirect_to path
  end

  private

    def load_conflict
      @conflict = Conflict.find(params[:id])
    end

    def load_caller
      if params.include? :rider_id
        @caller = :rider
        load_rider
      end
      load_root_key
    end

    def load_root_key
      @root_key = :conflict
      load_root_path
      # raise @root_path.inspect
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
        @conflicts = Conflict.where("conflicts.rider_id = ?", params[:rider_id]).order(:start)        
      when nil
        @conflicts = Conflict.all.order(:start)
      end
    end

    def conflict_params
      params.require(:conflict).permit(:id, :start, :end, :period, :rider_id, :root_path, :start)
    end
end
