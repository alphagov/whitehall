class AddLatestEditionInfoToContentBlockDocuments < ActiveRecord::Migration[7.1]
  def up
    ContentObjectStore::ContentBlock::Document.find_each do |document|
      if document.latest_edition_id.nil? || document.live_edition_id.nil?
        document.update!(
          latest_edition_id: document.content_block_editions.last.id,
          live_edition_id: document.content_block_editions.last.id,
        )
      end
    end
  end

  def down
    ContentObjectStore::ContentBlock::Document.update_all(
      latest_edition_id: nil,
      live_edition_id: nil,
    )
  end
end
