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

  classy_enum_attr :method, enum:'AgencyPaymentMethod' 
  validates :pickup_required, inclusion: { in: [ true, false ] }
end
