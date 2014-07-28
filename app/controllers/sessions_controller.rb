class SessionsController < ApplicationController

  skip_load_and_authorize_resource
  
  def new
  end

  def create
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash.now[:error] = "You must provide an email address and password."
      render 'new'
    else
      contact = Contact.find_by_email(params[:session][:email].downcase)
      if contact.nil?
        flash.now[:error] = "Sorry. We couldn't find a user with that email address."
        render 'new'
      else
        account = contact.contactable.account
        if account && account.authenticate(params[:session][:password])
          sign_in account
          redirect_back_or account.user
        else 
          flash.now[:error] = "Invalid email/password combination"
          render 'new'
        end
      end
    end 
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end