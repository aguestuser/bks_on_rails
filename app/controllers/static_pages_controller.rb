class StaticPagesController < ApplicationController
  def home
    redirect_to current_account.user if signed_in?
  end

  def manual
  end
end