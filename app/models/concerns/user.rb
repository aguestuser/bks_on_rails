module User
  extend ActiveSupport::Concern

  included do # instance methods
    #associations
    has_one :user_info, as: :user
    allow_nested_attributes_for :user_info

  end

  module ClassMethods
    
  end
end
