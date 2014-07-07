# == Schema Information
#
# Table name: work_arrangements
#
#  id                     :integer          not null, primary key
#  zone                   :string(255)
#  daytime_volume         :string(255)
#  evening_volume         :string(255)
#  pay_rate               :string(255)
#  shift_meal             :boolean
#  cash_out_tips          :boolean
#  rider_on_premises      :boolean
#  extra_work             :boolean
#  extra_work_description :string(255)
#  bike                   :boolean
#  lock                   :boolean
#  rack                   :boolean
#  bag                    :boolean
#  heated_bag             :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  restaurant_id          :integer
#  rider_payment_method   :string(255)
#

class WorkArrangement < ActiveRecord::Base
  belongs_to :restaurant

  classy_enum_attr :rider_payment_method

  validates :zone, :daytime_volume, :evening_volume, :rider_payment_method,
    presence: true
  validates :extra_work_description, 
    presence: true,
    if: 'extra_work'

end
