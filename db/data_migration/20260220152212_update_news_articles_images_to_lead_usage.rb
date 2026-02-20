news_article_types = %w[news_story world_news_story government_response press_release]
StandardEdition.where(configurable_document_type: news_article_types, state: "published").find_each do |edition|
  # History pages only have one translation, so we can safely take the first one.
  translation = edition.translations.first
  lead_image_data_id = translation.block_content["image"]

  # No sidebar image has been set, so we can skip this edition.
  if lead_image_data_id.present?
    image = Image.find_by(image_data_id: lead_image_data_id, edition_id: edition.id)
    image.update!(usage: "lead") if image
  end

  new_block_content = translation.block_content.except("image")
  translation.update_column(:block_content, new_block_content)

  # All the editions will need republishing.
  # Nonetheless, we observed on the previous run for history pages that the republish did not have any effect on some of the editions,
  # potentially due to the database write not being fully committed before the republish was triggered.
  # We will enqueue the republish manually after the migration is completed to ensure all the editions are republished.
end
