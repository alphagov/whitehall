class AddFulltextIndexToContentBlockEditions < ActiveRecord::Migration[8.0]
  INDEX_NAME = "title_details_instructions_to_publishers".freeze

  def up
    change_table :content_block_editions, bulk: true do |t|
      t.virtual :details_for_indexing, type: :text, as: "JSON_UNQUOTE(details)", stored: true
      t.index %i[title details_for_indexing instructions_to_publishers], name: INDEX_NAME, type: :fulltext
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove :details_for_indexing
    end
    remove_index :content_block_editions, name: INDEX_NAME
  end
end
