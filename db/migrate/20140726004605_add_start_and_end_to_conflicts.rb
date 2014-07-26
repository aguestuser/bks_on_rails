class AddStartAndEndToConflicts < ActiveRecord::Migration
  def change
    add_column :conflicts, :start, :datetime
    add_index :conflicts, :start
    add_column :conflicts, :end, :datetime
    add_index :conflicts, :end
  end
end
