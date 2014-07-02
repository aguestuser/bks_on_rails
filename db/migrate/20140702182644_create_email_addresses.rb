class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.boolean :primary
      t.string :value

      t.timestamps
    end
  end
end
