class AssetManager::AttachmentUpdater::LinkHeaderUpdates
  def self.call(attachment_data)
    visible_edition = attachment_data.visible_edition_for(nil)
    draft_edition = attachment_data.draft_edition

    parent_document_url = if visible_edition.blank? && draft_edition
                            draft_edition.public_url(draft: true)
                          elsif visible_edition.present?
                            visible_edition.public_url
                          else
                            return []
                          end

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
