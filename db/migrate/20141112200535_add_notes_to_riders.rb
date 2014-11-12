class AddNotesToRiders < ActiveRecord::Migration
  def change
    add_column :riders, :notes, :text
  end
end
