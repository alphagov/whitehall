class CreateDocumentRelations < ActiveRecord::Migration
  def change
    create_table :document_relations do |t|
      t.integer :document_id, null: false
      t.integer :related_document_id, null: false
      t.timestamps
    end
  end
end
