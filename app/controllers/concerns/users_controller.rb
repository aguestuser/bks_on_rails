 module UsersController
  include ControllerHelpers
  extend ActiveSupport::Concern

  included do  
    
    before_action :get_account, only: [:show, :edit, :update, :destroy]

    private

    def get_account
      @account = get_klass.find(params[:id]).account
      @contact = @account.contact
    end

    def build_account(user)
      user.build_account.build_contact
    end

    def refresh_account(user) 
      @account = user.account
      @contact = @account.contact
    end

    def account_params
      { 
        account_attributes: [
          :id, :user_id, :user_type, :password, :password_confirmation,
          contact_attributes: [
            :id, :contact_id, :name, :title, :email, :phone
          ]
        ] 
      }
    end
  end

  module ClassMethods
  end
end