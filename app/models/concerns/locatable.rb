module Locatable
  extend ActiveSuport::Concern
  included do
    has_one :location, as: :locatable, dependent: :destroy
    accepts_nested_attributes_for :location
  end

  module ClassMethods
  end
end