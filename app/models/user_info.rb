# == Schema Information
#
# Table name: user_infos
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  email      :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  user_type  :string(255)
#

class UserInfo < ActiveRecord::Base
  #associations
  belongs_to :user, polymorphic: true
  has_one :contact_info, as: :contact

  #before filters
  before_save { email.downcase! }

  #validations
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, 
              presence: true,
              format: { with: VALID_EMAIL },
              uniqueness: { case_sensitive: false }  

end
