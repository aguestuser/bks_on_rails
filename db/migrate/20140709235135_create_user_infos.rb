class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.string :title
      t.string :email
      t.references :user, index: true, polymorphous: true

      t.timestamps
    end
  end
end
