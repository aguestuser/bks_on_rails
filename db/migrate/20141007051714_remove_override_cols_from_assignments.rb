class RemoveOverrideColsFromAssignments < ActiveRecord::Migration
  def change
    remove_column :assignments, :override_conflict, :boolean
    remove_column :assignments, :override_double_booking, :boolean
  end
end
