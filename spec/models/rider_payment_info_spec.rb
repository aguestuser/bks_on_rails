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

require 'spec_helper'

describe RiderPaymentInfo do
  pending "add some examples to (or delete) #{__FILE__}"
end
