# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

class UserInfo < ActiveRecord::Base
  include Contact
  #associations
  belongs_to :user, polymorphic: true

end
