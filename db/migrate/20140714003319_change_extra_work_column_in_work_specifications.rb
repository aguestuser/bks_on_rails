class ChangeExtraWorkColumnInWorkSpecifications < ActiveRecord::Migration
  def change
    remove_column :work_specifications, :extra_work, :string
    add_column :work_specifications, :extra_work, :boolean
  end
end
