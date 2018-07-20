class AssetManager::AttachmentUpdater::LinkHeaderUpdates
  def self.call(attachment_data)
    visible_edition = attachment_data.visible_edition_for(nil)
    return [] unless visible_edition.present?

    parent_document_url = Whitehall.url_maker.public_document_url(visible_edition)

    Enumerator.new do |enum|
      enum.yield AssetManager::AttachmentUpdater::Update.new(
        attachment_data, attachment_data.file, parent_document_url: parent_document_url
      )

      if attachment_data.pdf?
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          attachment_data, attachment_data.file.thumbnail, parent_document_url: parent_document_url
        )
      end
    end
  end
end
