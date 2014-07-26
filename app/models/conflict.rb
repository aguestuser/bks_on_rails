# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  start      :datetime
#  end        :datetime
#

class Conflict < ActiveRecord::Base
  include Timeboxable

  belongs_to :rider

  validates :rider_id, presence: true

end
