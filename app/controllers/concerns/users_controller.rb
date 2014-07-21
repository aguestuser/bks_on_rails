 module UsersController
  extend ActiveSupport::Concern

  included do  
    
    # before_action :get_account, only: [:show, :edit, :update, :destroy]

    private

    # def build_account
    #   @it.build_account
    # end

    # def refresh_account
    #   @account = @it.account
    # end

    def account_params
      { 
        account_attributes: [
          :id, :user_id, :user_type, :password, :password_confirmation,
        ] 
      }
    end
  end

  module ClassMethods
  end
end