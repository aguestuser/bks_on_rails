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

require 'spec_helper'

describe AgencyPaymentInfo do
  pending "add some examples to (or delete) #{__FILE__}"
end
