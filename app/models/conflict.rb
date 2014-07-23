# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  date       :datetime
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Conflict < ActiveRecord::Base
  belongs_to :rider

  classy_enum_attr :period

  validates :rider_id, :period, :date, presence: true
end
