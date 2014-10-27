class StaticPagesController < ApplicationController
  skip_load_and_authorize_resource
  def home
    if signed_in?
      user = current_account.user
      if credentials == 'Manager'
        redirect_to restaurant_manager_path(user.restaurant, user)
      else 
        redirect_to user
      end
    else 
      redirect_to sign_in_path
    end
  end

  def manual
    if signed_in?
      if credentials == 'Staffer'
        render 'manual'
      else
        flash[:error] = "You don't have permission to view that page."
        redirect_to root_path
      end

    else
      redirect_to sign_in_path
    end
  end
end