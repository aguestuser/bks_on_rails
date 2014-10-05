# == Schema Information
#
# Table name: managers
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Manager < ActiveRecord::Base
  include User, Contactable, Importable # app/model/concerns/
  belongs_to :restaurant

end
