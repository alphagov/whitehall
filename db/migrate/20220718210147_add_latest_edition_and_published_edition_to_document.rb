class AddLatestEditionAndPublishedEditionToDocument < ActiveRecord::Migration[7.0]
  def up
    change_table :documents, bulk: true do |t|
      t.column :latest_edition_id, :integer
      t.column :live_edition_id, :integer
      t.index %i[latest_edition_id]
      t.index %i[live_edition_id]
    end

    add_foreign_key :documents, :editions, column: :latest_edition_id
    add_foreign_key :documents, :editions, column: :live_edition_id

    # Backfill live_edition_id
    execute <<-SQL
      UPDATE documents
      SET live_edition_id = (
        SELECT MAX(id)
        FROM editions
        WHERE documents.id = editions.document_id
        AND editions.state IN ('published', 'withdrawn')
      )
    SQL

    # Backfill latest_edition_id
    execute <<-SQL
      UPDATE documents
      SET latest_edition_id = (
        SELECT MAX(id)
        FROM editions
        WHERE documents.id = editions.document_id
        AND editions.state != 'deleted'
      )
    SQL
  end

  def down
    remove_foreign_key :documents, :editions, column: :latest_edition_id
    remove_foreign_key :documents, :editions, column: :live_edition_id

    change_table :documents, bulk: true do |t|
      t.remove :latest_edition_id
      t.remove :live_edition_id
      t.remove_index :latest_edition_id
      t.remove_index :live_edition_id
    end
  end
end
