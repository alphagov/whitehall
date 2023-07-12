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

    if attachment_data.assets.empty?
      Enumerator.new do |enum|
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          nil, attachment_data, attachment_data.file, parent_document_url:
        )

        if attachment_data.pdf?
          enum.yield AssetManager::AttachmentUpdater::Update.new(
            nil, attachment_data, attachment_data.file.thumbnail, parent_document_url:
          )
        end
      end
    else
      # Both the file and its thumbnail are now represented by an Asset
      # and rely solely on the asset_manager_id rather than the legacy_url_path for updates.
      # Therefore, it is not needed to check whether or not the Attachment is a pdf.
      Enumerator.new do |enum|
        attachment_data.assets.each do |asset|
          enum.yield AssetManager::AttachmentUpdater::Update.new(
            asset.asset_manager_id, attachment_data, nil, parent_document_url:
          )
        end
      end
    end
  end
end
