class CreateConflicts < ActiveRecord::Migration
  def change
    create_table :conflicts do |t|
      t.datetime :date
      t.string :period
      t.references :rider, index: true

      t.timestamps
    end
  end
end
