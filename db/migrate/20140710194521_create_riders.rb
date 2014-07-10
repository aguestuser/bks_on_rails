class CreateRiders < ActiveRecord::Migration
  def change
    create_table :riders do |t|
      t.boolean :active

      t.timestamps
    end
  end
end
