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

  validates :restaurant_id, :start, :end, :billing_rate, :urgency,
    presence: true
  validate :start_before_end

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



  private


end
