class RemoveDateFromConflicts < ActiveRecord::Migration
  def change
    remove_column :conflicts, :date, :datetime
  end
end
