class AddUserTypeToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :user_type, :string
  end
end
