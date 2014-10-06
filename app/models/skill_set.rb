# == Schema Information
#
# Table name: skill_sets
#
#  id            :integer          not null, primary key
#  rider_id      :integer
#  bike_repair   :boolean
#  fix_flats     :boolean
#  early_morning :boolean
#  pizza         :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

class SkillSet < ActiveRecord::Base
  include Importable
  belongs_to :rider

  validates :bike_repair, :fix_flats, :early_morning, :pizza,
    inclusion: { in: [ true, false ] }
end
