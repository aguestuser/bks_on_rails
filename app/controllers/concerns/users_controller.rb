 module UsersController
  extend ActiveSupport::Concern

  included do
    before_filter :get_user    

    private

      # def get_user
      #   @user = self.user_info
      #   @contact = @user.contact_info 
      # end

    def user_info_params
      { 
        user_info_attributes: [
          :id, :user_id, :user_type,
          contact_info_attributes: [
            :id, :contact_id, :name, :title, :email, :phone
          ]
        ] 
      }
    end
  end

  module ClassMethods
  end
end