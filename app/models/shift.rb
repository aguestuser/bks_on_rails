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

  classy_enum_attr :period
  classy_enum_attr :billing_rate
  classy_enum_attr :urgency

  validates :start, :end, :period, :billing_rate, :urgency,
    presence: true
end
