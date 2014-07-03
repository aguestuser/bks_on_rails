class ChangeContactInfoFields < ActiveRecord::Migration
  change_table :contact_infos do |t|
    t.rename :email_address, :email
    t.rename :phone_number, :phone
  end
end
