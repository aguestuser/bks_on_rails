module User
  extend ActiveSupport::Concern

  included do # instance methods
    #associations
    has_one :account, as: :user, dependent: :destroy
      accepts_nested_attributes_for :account

  end

  module ClassMethods
    # def find_by_email(email)
    #   klass = name.constantize
    #   users = klass.joins(:account).where(:user_infos => {:email => email})
    #   if users.count == 1
    #     users.first
    #   else
    #     raise "There were more than one user with that email!"
    #   end
    # end  
  end
end
