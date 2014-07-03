require_relative '20140702182644_create_email_addresses.rb'

class RevertEmailAddresses < ActiveRecord::Migration
  def change
    revert CreateEmailAddresses
  end
end
