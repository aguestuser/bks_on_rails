class RemoveTitleFromStaffer < ActiveRecord::Migration
  def change
    remove_column :staffers, :title, :string
  end
end
