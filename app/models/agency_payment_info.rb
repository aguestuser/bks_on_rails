# == Schema Information
#
# Table name: agency_payment_infos
#
#  id              :integer          not null, primary key
#  method          :string(255)
#  pickup_required :boolean
#  restaurant_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class AgencyPaymentInfo < ActiveRecord::Base
  belongs_to :restaurant
  validates :method, :pickup_required, presence: true
end
