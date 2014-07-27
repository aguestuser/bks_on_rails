class AddOverrideConflictToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :override_conflict, :boolean
    add_column :assignments, :override_double_booking, :boolean
  end
end
