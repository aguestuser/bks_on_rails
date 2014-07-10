class RemoveEmailFromContactInfos < ActiveRecord::Migration
  def change
    remove_column :contact_infos, :email, :string
  end
end
