class AddLatestEditionStateToContentBlockDocuments < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_documents, bulk: true do |t|
      t.column :latest_edition_id, :integer
      t.column :live_edition_id, :integer
      t.index :latest_edition_id
      t.index :live_edition_id
    end
  end

  def down
    change_table :content_block_documents, bulk: true do |t|
      t.remove :latest_edition_id
      t.remove :live_edition_id
      t.remove_index :latest_edition_id
      t.remove_index :live_edition_id
    end
  end
end
