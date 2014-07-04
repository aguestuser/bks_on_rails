class AddFieldsToStaffers < ActiveRecord::Migration
  def change
    add_column :staffers, :title, :string
    add_column :staffers, :contact_info_id, :integer
    add_index :staffers, :contact_info_id
  end
end
