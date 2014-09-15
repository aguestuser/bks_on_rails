# == Schema Information
#
# Table name: shifts
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  start         :datetime
#  end           :datetime
#  period        :string(255)
#  urgency       :string(255)
#  billing_rate  :string(255)
#  notes         :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Shift < ActiveRecord::Base
  include Timeboxable, BatchUpdatable

  belongs_to :restaurant
  has_one :assignment, dependent: :destroy #inverse_of: :shift
    accepts_nested_attributes_for :assignment

  
  classy_enum_attr :billing_rate
  classy_enum_attr :urgency

  validates :restaurant_id, :billing_rate, :urgency,
    presence: true

  def build_associations
    self.assignment = Assignment.new
  end

  def rider
    self.assignment.rider
  end

  def assigned? #output: bool
    !self.assignment.rider.nil?
  end

  def assign_to(rider, status=:proposed) 
    #input: Rider, AssignmentStatus(Symbol) 
    #output: self.Assignment
    params = { rider_id: rider.id, status: status } 
    if self.assigned?
      self.assignment.update params
    else
      self.assignment = Assignment.create! params
    end
  end

  def unassign
    self.assignment.update(rider_id: nil, status: :unassigned) if self.assigned?
  end

  def conflicts_with? conflict
    ( conflict.end >= self.end && conflict.start < self.end ) || 
    ( conflict.start <= self.start && conflict.end > self.start )
    # ie: if the conflict under examination overlaps with this conflict 
  end

  def double_books_with? shift
    ( shift.end >= self.end && shift.start <  self.end ) || 
    ( shift.start <= self.start && shift.end > self.start )
    # ie: if the shift under examination overlaps with this shift
  end

  def refresh_urgency now
    #input self (implicit), DateTime Obj
    #side-effects: updates shift's urgency attribute
    #output: self 
      
    start = self.start
    send_urgency( parse_urgency( now, start ) ) if start > now 
    self
  end

  private

    def parse_urgency now, start
      #input: Datetime, Datetime
      #output: Symbol
      next_week = start.beginning_of_week != now.beginning_of_week
      time_gap = start - now
      
      if next_week
        :weekly
      elsif time_gap <= 36.hours
        :emergency
      else
        :extra
      end
    end

    def send_urgency urgency
      #input: Symbol
      self.update(urgency: urgency)
    end  

end
