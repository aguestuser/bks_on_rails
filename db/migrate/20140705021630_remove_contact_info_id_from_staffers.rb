class RemoveContactInfoIdFromStaffers < ActiveRecord::Migration
  def change
    remove_column :staffers, :contact_info_id, :integer
  end
end
