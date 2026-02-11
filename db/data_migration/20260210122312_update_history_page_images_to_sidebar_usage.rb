StandardEdition.where(configurable_document_type: "history_page", state: "published").find_each do |edition|
  # History pages only have one translation, so we can safely take the first one.
  translation = edition.translations.first
  sidebar_image_data_id = translation.block_content["sidebar_image"]

  # No sidebar image has been set, so we can skip this edition.
  if sidebar_image_data_id.present?
    image = Image.find_by(image_data_id: sidebar_image_data_id, edition_id: edition.id)
    image.update!(usage: "sidebar") if image
  end

  new_block_content = translation.block_content.except("sidebar_image")
  translation.update_column(:block_content, new_block_content)

  # Republish the edition to ensure update payload is sent to Publishing API. We don't actually expect that the payload would be different, except for captions being dropped when blank.
  PublishingApiDocumentRepublishingWorker.perform_async(edition.document.id, false)
end
