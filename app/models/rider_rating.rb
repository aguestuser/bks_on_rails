# == Schema Information
#
# Table name: rider_ratings
#
#  id             :integer          not null, primary key
#  rider_id       :integer
#  initial_points :integer
#  likeability    :integer
#  reliability    :integer
#  speed          :integer
#  points         :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class RiderRating < ActiveRecord::Base
  include Importable
  belongs_to :rider
  after_validation :init_points, on: :create

  RATINGS = [1, 2, 3]
  INITIAL_POINTS = [75, 80, 90, 100]

  validates :likeability, :reliability, :speed,
    presence: true,
    numericality: true,
    inclusion: { in: RATINGS }
  validates :initial_points,
    presence: true,
    numericality: true,
    inclusion: { in: INITIAL_POINTS }

  private
    def init_points
      self.points = initial_points
    end
end
