class AssetManager::AttachmentUpdater::DraftStatusUpdates
  def self.call(attachment_data)
    draft = (attachment_data.draft? && !attachment_data.unpublished? && !attachment_data.replaced?) || (attachment_data.unpublished? && !attachment_data.present_at_unpublish? && !attachment_data.replaced?)

    Enumerator.new do |enum|
      enum.yield AssetManager::AttachmentUpdater::Update.new(
        attachment_data, attachment_data.file, draft: draft
      )

      if attachment_data.pdf?
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          attachment_data, attachment_data.file.thumbnail, draft: draft
        )
      end
    end
  end
end
