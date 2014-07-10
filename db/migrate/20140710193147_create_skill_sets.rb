class CreateSkillSets < ActiveRecord::Migration
  def change
    create_table :skill_sets do |t|
      t.references :rider, index: true
      t.boolean :bike_repair
      t.boolean :fix_flats
      t.boolean :early_morning
      t.boolean :pizza

      t.timestamps
    end
  end
end
