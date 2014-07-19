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
  belongs_to :restaurant
  has_one :assignment
    accepts_nested_attributes_for :assignment

  classy_enum_attr :period, allow_nil: true
  classy_enum_attr :billing_rate
  classy_enum_attr :urgency

  validates :start, :end, :billing_rate, :urgency,
    presence: true
  validate :start_before_end

  def start_before_end
    if self.end.present? && start.present? && self.end <= start
      errors.add(:end, "can't be before start")
    end  
  end
end
