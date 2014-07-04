class AddTitleToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :title, :string
  end
end
