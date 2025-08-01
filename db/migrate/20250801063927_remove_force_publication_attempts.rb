class RemoveForcePublicationAttempts < ActiveRecord::Migration[8.0]
  def up
    drop_table :force_publication_attempts
  end

  def down
    create_table :force_publication_attempts do |t|
      t.string :import_id
      t.integer :total_documents
      t.integer :successful_documents
      t.text :log
      t.timestamps
    end
  end
end
