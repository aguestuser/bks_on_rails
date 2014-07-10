class RemoveSkillsFromQualificationSets < ActiveRecord::Migration
  def change
    remove_column :qualification_sets, :skills, :string
  end
end
