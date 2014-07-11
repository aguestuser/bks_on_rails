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

class Account < ActiveRecord::Base
  #associations
  belongs_to :user, polymorphic: true

  has_one :contact, dependent: :destroy
    accepts_nested_attributes_for :contact

  def email
    self.contact.email
  end

end
