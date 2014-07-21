class AccountsController < ApplicationController

  before_action :load_account, only: [ :edit, :update ]

  def create
  end

  def show
  end

  def edit
  end

  def update
    @account.update(account_params)
    if @account.save
      flash[:success] = 'Account settings updated'
      redirect_to current_account.user
    else
      render 'edit'
    end
  end

  private

    def load_account
      @account = current_account
      @it = @account
    end

    def account_params
      params.require(:account).permit(:user_id, :password, :password_confirmation)
    end
end
