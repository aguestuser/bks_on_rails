class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  # before_action :check_sign_in
  authorize_resource

  def now_unless_test
    Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now
  end

  
  # CanCan config
  def current_ability
    @current_ability ||= Ability.new(current_account)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_back_or root_path
  end

  def check_sign_in
    unless params[:controller] == 'sessions'
      redirect_to sign_in_path unless signed_in?
    end
  end
end
