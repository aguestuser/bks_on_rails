module User
  extend ActiveSupport::Concern

  included do # instance methods
    #associations
    has_one :account, as: :user, dependent: :destroy
      accepts_nested_attributes_for :account

  end

  module ClassMethods
  end
end
