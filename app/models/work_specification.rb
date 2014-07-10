# == Schema Information
#
# Table name: work_specifications
#
#  id                     :integer          not null, primary key
#  restaurant_id          :integer
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  extra_work             :string(255)
#  extra_work_description :text
#  created_at             :datetime
#  updated_at             :datetime
#

class WorkSpecification < ActiveRecord::Base
  belongs_to :restaurant
end
