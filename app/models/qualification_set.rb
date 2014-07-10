# == Schema Information
#
# Table name: qualification_sets
#
#  id                :integer          not null, primary key
#  hiring_assessment :text
#  experience        :text
#  geography         :text
#  created_at        :datetime
#  updated_at        :datetime
#  rider_id          :integer
#

class QualificationSet < ActiveRecord::Base
  belongs_to :rider

  validates :hiring_assessment, :experience, :geography, presence: true

end
