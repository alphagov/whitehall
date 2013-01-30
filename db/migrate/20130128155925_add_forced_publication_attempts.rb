class AddForcedPublicationAttempts < ActiveRecord::Migration
  def change
    create_table :force_publication_attempts, force: true do |t|
      t.integer :import_id
      t.integer :total_documents
      t.integer :successful_documents
      t.datetime :enqueued_at
      t.datetime :started_at
      t.datetime :finished_at
      t.text :log, limit: 2147483647

      t.timestamps
    end

    add_index :force_publication_attempts, :import_id
  end
end
