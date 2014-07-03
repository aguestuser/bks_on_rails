require_relative '20140702175140_create_phone_numbers.rb'

class RevertPhoneNumbers < ActiveRecord::Migration
  def change
    revert CreatePhoneNumbers
  end
end
