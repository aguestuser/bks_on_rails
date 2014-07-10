class DropWorkArrangement < ActiveRecord::Migration
  def up
    drop_table :work_arrangements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
