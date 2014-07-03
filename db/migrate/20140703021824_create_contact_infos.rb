class CreateContactInfos < ActiveRecord::Migration
  def change
    create_table :contact_infos do |t|
      t.string :phone_number
      t.string :email_address
      t.string :street_address
      t.string :borough
      t.string :neighborhood

      t.timestamps
    end
  end
end
