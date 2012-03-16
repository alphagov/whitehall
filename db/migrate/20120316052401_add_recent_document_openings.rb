class AddRecentDocumentOpenings < ActiveRecord::Migration
  def change
    create_table :recent_document_openings do |t|
      t.integer  :document_id, null: false
      t.integer  :editor_id,   null: false
      t.datetime :created_at,  null: false
    end

    add_index :recent_document_openings, [:document_id, :editor_id], unique: true
  end
end
