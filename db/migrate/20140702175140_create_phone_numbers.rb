class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :type
      t.boolean :primary
      t.string :value

      t.timestamps
    end
  end
end
