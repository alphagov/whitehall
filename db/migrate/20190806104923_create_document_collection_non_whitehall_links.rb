class CreateDocumentCollectionNonWhitehallLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :document_collection_non_whitehall_links do |t|
      t.string :content_id, null: false
      t.string :title, null: false
      t.text :base_path, null: false
      t.string :publishing_app, null: false
      t.timestamps
    end
  end
end
