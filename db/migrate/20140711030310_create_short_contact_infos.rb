class CreateShortContactInfos < ActiveRecord::Migration
  def change
    create_table :short_contact_infos do |t|
      t.string :name
      t.string :phone
      t.references :restaurant, index: true

      t.timestamps
    end
  end
end
