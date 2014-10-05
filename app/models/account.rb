# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  user_type       :string(255)
#  password_digest :string(255)
#  remember_token  :string(255)
#

class Account < ActiveRecord::Base
  include Importable
  #associations
  belongs_to :user, polymorphic: true

  #callbacks
  before_create :create_remember_token

  #validations
  has_secure_password
  validates :password, length: { minimum: 6 }


  #class methods
  def Account.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def Account.digest(token)
    Digest::SHA1.hexdigest(token.to_s) #call .to_s to handle test cases in which token is nil
  end

  private

    def create_remember_token
      self.remember_token = Account.digest(Account.new_remember_token)
    end

end
