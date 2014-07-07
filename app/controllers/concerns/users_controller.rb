module UsersController
  extend ActiveSupport::Concern

  included do
    before_filter :get_user    
    # before_action :get_user, only: [:show, :edit, :update, :destroy]
    case @klass
    when Staffer
    
    when Manager
    
    when Rider  

    end

    private

      def get_user
        @klass = name.constantize
        @user = klass.find(params[:id]) 
      end

      # def user_params
      #   params.require(:user).permit(contact_info_attributes: [:name, :title, :phone, :email])
      # end
  end

  module ClassMethods
  end
end