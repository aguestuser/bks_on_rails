class SessionsController < ApplicationController

  skip_load_and_authorize_resource
  
  def new
  end

  def create
    unless params[:session][:email].blank?
      contact = Contact.find_by_email(params[:session][:email].downcase)
      account = contact.contactable.account
    end
    if account && account.authenticate(params[:session][:password])
      sign_in account
      redirect_back_or account.user
    else 
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end