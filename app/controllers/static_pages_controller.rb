class StaticPagesController < ApplicationController
  skip_load_and_authorize_resource
  def home
    if signed_in?
      redirect_to current_account.user 
    else 
      redirect_to sign_in_path
    end
  end

  def manual
  end
end