class MoveEmailAndTitleFromUserInfoToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :email, :string
    add_column :contact_infos, :title, :string
    remove_column :user_infos, :email, :string
    remove_column :user_infos, :title, :string
  end
end
