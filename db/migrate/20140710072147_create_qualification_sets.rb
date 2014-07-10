class CreateQualificationSets < ActiveRecord::Migration
  def change
    create_table :qualification_sets do |t|
      t.text :hiring_assessment
      t.text :experience
      t.text :geography
      t.string :skills

      t.timestamps
    end
  end
end
