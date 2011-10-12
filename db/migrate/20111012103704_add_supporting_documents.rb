class AddSupportingDocuments < ActiveRecord::Migration
  def change
    create_table :supporting_documents, force: true do |t|
      t.references :document
      t.string :title
      t.text :body
      t.timestamps
    end
  end
end