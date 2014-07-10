module User
  extend ActiveSupport::Concern

  included do # instance methods
    include Contact
    #associations
    has_one :user_info, as: :user, dependent: :destroy
      accepts_nested_attributes_for :user_info

    def email
      self.user_info.email
    end

    def title
      self.user_info.title
    end

  end

  module ClassMethods
    def find_by_email(email)
      klass = name.constantize
      users = klass.joins(:user_info).where(:user_infos => {:email => email})
      if users.count == 1
        users.first
      else
        raise "There were more than one user with that email!"
      end
    end  
  end
end
