class CreateLicences < ActiveRecord::Migration[7.0]
  def change
    create_table :licences do |t|
      t.string :link, null: false
      t.text :title
      t.text :sectors, array: true
      t.text :activities, array: true
      t.timestamps
    end
  end
end
