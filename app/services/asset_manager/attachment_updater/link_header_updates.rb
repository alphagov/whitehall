class AssetManager::AttachmentUpdater::LinkHeaderUpdates
  def self.call(attachment_data)
    visible_edition = attachment_data.visible_edition_for(nil)
    return [] if visible_edition.blank?

    parent_document_url = visible_edition.public_url(locale: I18n.default_locale)

    Enumerator.new do |enum|
      enum.yield AssetManager::AttachmentUpdater::Update.new(
        attachment_data, attachment_data.file, parent_document_url:
      )

      if attachment_data.pdf?
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          attachment_data, attachment_data.file.thumbnail, parent_document_url:
        )
      end
    end
  end
end
