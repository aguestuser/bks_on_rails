class AssignmentsController < ApplicationController
  
  before_action :load_assignment, only: [ :show, :edit, :update, :destroy ]
  before_action :load_shift, if: :shift_present?
  before_action :load_rider, if: :rider_present?
  before_action :load_assignments, only: :index


  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      flash[:success] = "Shift assigned to @rider.contact.name"
      render 'index'
    else
      render 'new'
    end
    
  end

  def edit
  end

  def update
    @assignment.update(assignment_params)
    if @assignment.save
      flash[:success] = "Assignment updated"
      render 'index'
    else
      render 'edit'
    end
  end

  def show
  end

  def index
  end

  def destroy
    
  end

  private 

    def load_assignment
      @assignment = Assignment.find(params[:id])  
    end

    def shift_present?
      params.include? :shift_id
    end

    def load_shift
      @shift = Shift.find(params[:shift_id])
    end

    def rider_present?
      params.include? :rider_id
    end

    def load_rider
      @rider = Rider.find(params[:rider_id])
    end    

    def load_assignments
      if shift_present?
        @assignments = Assignment.where(shift: params[:shift_id])
      elsif rider_present?
        @assignments = Assignment.where(rider_id: params[:rider_id])
      else
        @assignments = Assignment.all
      end 
    end

    def assignment_params
      params
        .require(:assignment)
        .permit(:rider_id, :shift_id, :status)
    end


end
