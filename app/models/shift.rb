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
  include Timeboxable

  belongs_to :restaurant
  has_one :assignment, dependent: :destroy
    accepts_nested_attributes_for :assignment

  
  classy_enum_attr :billing_rate
  classy_enum_attr :urgency

  validates :restaurant_id, :billing_rate, :urgency,
    presence: true

  def assigned? #output: bool
    !self.assignment.nil?
  end

  def assign_to(rider) #input: Rider, #output: self.Assignment
    if self.assigned?
      self.assignment.update(rider_id: rider.id)
    else 
      self.assignment = Assignment.create!(shift_id: self.id, rider_id: rider.id)
    end
  end

  def conflicts_with?(conflicts)
    conflicts.each do |conflict|
      return true if ( conflict.end >= self.end && conflict.start < self.end ) || ( conflict.start <= self.start && conflict.end > self.start ) 
      # ie: if the conflict under examination overlaps with this shift
    end
    false
  end

  def double_books_with?(shifts)
    shifts.each do |shift|
      return true if ( shift.end >= self.end && shift.start <  self.end ) || ( shift.start <= self.start && shift.end > self.start )
      # ie: if the shift under examination overlaps with this shift
    end
    false
  end

  private


end
