class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.belongs_to :shift
      t.belongs_to :rider
      t.string :status
      t.timestamps
    end
  end
end
