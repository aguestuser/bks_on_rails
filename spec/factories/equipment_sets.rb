# == Schema Information
#
# Table name: equipment_sets
#
#  id             :integer          not null, primary key
#  equipable_id   :integer
#  equipable_type :string(255)
#  bike           :boolean
#  lock           :boolean
#  helmet         :boolean
#  rack           :boolean
#  bag            :boolean
#  heated_bag     :boolean
#  cell_phone     :boolean
#  smart_phone    :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  car            :boolean
#

FactoryGirl.define do
  factory :equipment_set do
    bike true
    lock true
    helmet true
    rack true
    bag true
    heated_bag true
    cell_phone true
    smart_phone true
    car false
    trait :with_equipable do |equipable|
      equipable
    end
    trait :without_equipable do
      equipable_id 0
    end
  end
end
