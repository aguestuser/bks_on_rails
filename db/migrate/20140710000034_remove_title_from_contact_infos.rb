class RemoveTitleFromContactInfos < ActiveRecord::Migration
  def change
    remove_column :contact_infos, :title, :string
  end
end
