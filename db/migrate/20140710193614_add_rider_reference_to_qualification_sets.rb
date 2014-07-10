class AddRiderReferenceToQualificationSets < ActiveRecord::Migration
  def change
    add_reference :qualification_sets, :rider, index: true
  end
end
