class CreateOperationalFields < ActiveRecord::Migration
  def change
    create_table :operational_fields do |t|
      t.string :name

      t.timestamps
    end
  end
end
