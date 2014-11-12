class AddNotesToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :notes, :text
  end
end
