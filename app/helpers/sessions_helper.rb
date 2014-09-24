module SessionsHelper
  def sign_in(account)
    remember_token = Account.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    account.update_attribute(:remember_token, Account.digest(remember_token))
    self.current_account = account
  end

  def signed_in?
    !current_account.nil?
  end

  def current_account=(account)
    @current_account = account
  end

  def current_account
    remember_token = Account.digest(cookies[:remember_token])
    @current_account ||= Account.find_by(remember_token: remember_token)
  end

  def credentials
    current_account.user_type
  end

  def current_account?(account)
    account == current_account
  end

  def staffer_signed_in?
    current_account && current_account.user_type == 'Staffer'
  end

  def signed_in_account
    unless signed_in?
      store_location
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end

  def sign_out
    current_account.update_attribute(:remember_token, Account.digest(Account.new_remember_token))
    cookies.delete(:remember_token)
    self.current_account = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

end
