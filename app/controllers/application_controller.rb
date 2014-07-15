class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :check_sign_in

  def check_sign_in
    unless params[:controller] == 'sessions'
      redirect_to sign_in_path unless signed_in?
    end
  end
end
