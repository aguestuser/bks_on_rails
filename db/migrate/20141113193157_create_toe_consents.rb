class CreateToeConsents < ActiveRecord::Migration
  def change
    create_table :toe_consents do |t|
      t.string :ip
      t.references :rider, index: true

      t.timestamps
    end
  end
end
