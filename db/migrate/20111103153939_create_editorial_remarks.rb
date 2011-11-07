class CreateEditorialRemarks < ActiveRecord::Migration
  def change
    create_table :editorial_remarks, force: true do |t|
      t.text :body
      t.references :document
      t.references :author
      t.timestamps
    end
  end
end