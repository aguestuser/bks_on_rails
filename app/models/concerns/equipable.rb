module Equipable
  extend ActiveSupport::Concern
  included do
    has_one :equipment_set, as: :equipable, dependent: :destroy
      accepts_nested_attributes_for :equipment_set
  end

  module ClassMethods
  end
end