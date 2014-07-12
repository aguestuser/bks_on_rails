 module UsersController
  extend ActiveSupport::Concern

  included do  
    # before_action :get_user_klass
    # after_action :build_account, only: :create
    before_action :get_account, only: [:show, :edit, :update, :destroy]

    private

    def get_user_klass
      @klass = params[:controller].singularize.capitalize.constantize      
    end

    def get_account
      get_user_klass
      @user = @klass.find(params[:id])
      @account = @user.account
      @contact = @account.contact
    end

    def build_account(user)
      @user = self.instance_variable_get "@#{controller_name.singularize}" 
      @user.build_account.build_contact
    end

    def refresh_account(user) 
      @account = user.account
      @contact = @account.contact
    end

    def account_params
      { 
        account_attributes: [
          :id, :user_id, :user_type,
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