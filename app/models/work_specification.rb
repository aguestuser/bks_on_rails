# == Schema Information
#
# Table name: work_specifications
#
#  id                     :integer          not null, primary key
#  restaurant_id          :integer
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  extra_work_description :text
#  created_at             :datetime
#  updated_at             :datetime
#  extra_work             :boolean
#

class WorkSpecification < ActiveRecord::Base
  belongs_to :restaurant

  validates :zone, :daytime_volume, :evening_volume, presence: true
  validates :extra_work, inclusion: { in: [ true, false ] }
  validates :extra_work_description, presence: true, if: :extra_work 

end
