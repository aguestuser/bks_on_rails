# == Schema Information
#
# Table name: rider_payment_infos
#
#  id            :integer          not null, primary key
#  restaurant_id :integer
#  method        :string(255)
#  rate          :string(255)
#  shift_meal    :boolean
#  cash_out_tips :boolean
#  created_at    :datetime
#  updated_at    :datetime
#

class RiderPaymentInfo < ActiveRecord::Base
  belongs_to :restaurant

  classy_enum_attr :method, enum: 'RiderPaymentMethod'

  validates :method, :rate, presence: true
  validates :shift_meal, :cash_out_tips, inclusion: { in: [ true, false ] }
end
